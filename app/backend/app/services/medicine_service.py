from datetime import datetime, timezone
from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.medicine import MedicineCreate, MedicineUpdate
from app.websocket import events as ws_events


class MedicineService:
    def create_medicine(self, data: MedicineCreate) -> str:
        doc_ref = db.collection(Collections.MEDICINES.value).document()
        payload = data.model_dump(exclude_unset=True)
        if "status" not in payload:
            payload["status"] = "PENDING"
        if "retry_count" not in payload:
            payload["retry_count"] = 0
        doc_ref.set(payload)
        return doc_ref.id

    def get_medicine(self, medicine_id: str):
        doc = db.collection(Collections.MEDICINES.value).document(medicine_id).get()

        if not doc.exists:
            return None

        return {
            "id": doc.id,
            **doc.to_dict(),
        }

    def update_medicine(self, medicine_id: str, data: MedicineUpdate) -> None:
        db.collection(Collections.MEDICINES.value).document(medicine_id).update(data.model_dump(exclude_unset=True))

    def delete_medicine(self, medicine_id: str) -> None:
        db.collection(Collections.MEDICINES.value).document(medicine_id).delete()

    def list_medicines(self):
        docs = db.collection(Collections.MEDICINES.value).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def list_medicines_by_patient(self, patient_id: str):
        docs = db.collection(Collections.MEDICINES.value).where("patient_id", "==", patient_id).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def send_medicine_to_robot(self, medicine_id: str) -> bool:
        """Publish a medication command to the patient's robot via MQTT.
        Returns True if the command was published, False otherwise.
        This is the integration point for Phase 5 Batch 2 scheduling.
        """
        medicine = self.get_medicine(medicine_id)
        if not medicine:
            return False

        patient_id = medicine.get("patient_id")
        if not patient_id:
            return False

        # Find patient's robot(s)
        robot_docs = db.collection(Collections.ROBOTS.value).where("user_id", "==", patient_id).stream()
        published = False
        for doc in robot_docs:
            robot_data = doc.to_dict() or {}
            robot_id_field = robot_data.get("robot_id")
            if robot_id_field:
                try:
                    from app.mqtt.mqtt_service import MQTTService
                    # Ensure medicine dict contains id
                    medicine_payload = {**medicine, "id": medicine_id}
                    MQTTService.publish_medicine_command(robot_id_field, medicine_payload)
                    published = True
                except Exception:
                    pass  # MQTT failure is non-fatal
        return published

    def process_scheduled_medicines(self) -> None:
        """Scan all medicines and process pending ones that are due, or retry reminded ones."""
        now = datetime.now(timezone.utc)

        # 1. Process PENDING medicines that are due
        docs = db.collection(Collections.MEDICINES.value).where("status", "==", "PENDING").stream()
        for doc in docs:
            data = doc.to_dict() or {}
            sched_val = data.get("scheduled_time")
            if not sched_val:
                continue
            try:
                if isinstance(sched_val, str):
                    dt = datetime.fromisoformat(sched_val.replace("Z", "+00:00"))
                elif isinstance(sched_val, datetime):
                    dt = sched_val
                else:
                    continue
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)

                if dt <= now:
                    # Time is due!
                    self.send_medicine_to_robot(doc.id)
                    update_data = {}
                    if data.get("requires_confirmation", True):
                        update_data["status"] = "REMINDED"
                        update_data["last_sent_at"] = now.isoformat()
                        update_data["retry_count"] = 0
                    else:
                        update_data["status"] = "COMPLETED"
                    db.collection(Collections.MEDICINES.value).document(doc.id).update(update_data)

                    # WebSocket: medication reminder/completed broadcast
                    patient_id = data.get("patient_id")
                    if patient_id:
                        ws_events.broadcast_medication(patient_id, {
                            "medicine_id": doc.id,
                            "status": update_data["status"],
                            "medicine_name": data.get("medicine_name"),
                            "dosage": data.get("dosage"),
                        })
            except Exception:
                continue

        # 2. Process REMINDED medicines that need confirmation/retry
        reminded_docs = db.collection(Collections.MEDICINES.value).where("status", "==", "REMINDED").stream()
        for doc in reminded_docs:
            data = doc.to_dict() or {}
            if not data.get("requires_confirmation", True):
                continue
            sent_val = data.get("last_sent_at") or data.get("scheduled_time")
            if not sent_val:
                continue
            try:
                if isinstance(sent_val, str):
                    dt = datetime.fromisoformat(sent_val.replace("Z", "+00:00"))
                elif isinstance(sent_val, datetime):
                    dt = sent_val
                else:
                    continue
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)

                # Retry interval is 30 seconds
                if (now - dt).total_seconds() >= 30:
                    retries = int(data.get("retry_count", 0))
                    if retries < 3:
                        # Resend
                        self.send_medicine_to_robot(doc.id)
                        db.collection(Collections.MEDICINES.value).document(doc.id).update({
                            "retry_count": retries + 1,
                            "last_sent_at": now.isoformat()
                        })
                    else:
                        # Max retries reached: Mark as MISSED and escalate to caregiver
                        db.collection(Collections.MEDICINES.value).document(doc.id).update({
                            "status": "MISSED"
                        })
                        patient_id = data.get("patient_id")
                        medicine_name = data.get("medicine_name", "Unknown medicine")
                        dosage = data.get("dosage", "")

                        # WebSocket: medication missed broadcast
                        if patient_id:
                            ws_events.broadcast_medication(patient_id, {
                                "medicine_id": doc.id,
                                "status": "MISSED",
                                "medicine_name": medicine_name,
                                "dosage": dosage,
                            })

                        if patient_id:
                            cg_docs = db.collection(Collections.CAREGIVERS.value).where("assigned_patient_id", "==", patient_id).stream()
                            for cg_doc in cg_docs:
                                cg_data = cg_doc.to_dict() or {}
                                if cg_data.get("is_primary") is True:
                                    notif_payload = {
                                        "title": f"MEDICATION MISSED: {medicine_name}",
                                        "message": f"Medication reminder ({medicine_name}, dosage: {dosage}) missed for patient {patient_id}. No confirmation received after {retries} attempts.",
                                        "recipient_id": cg_doc.id,
                                        "notification_type": "MEDICINE",
                                        "priority": "HIGH",
                                        "is_read": False,
                                        "created_at": datetime.now(timezone.utc).isoformat(),
                                    }
                                    notif_ref = db.collection(Collections.NOTIFICATIONS.value).document()
                                    notif_ref.set(notif_payload)
                                    try:
                                        ws_events.broadcast_notification(cg_doc.id, {**notif_payload, "id": notif_ref.id})
                                    except Exception:
                                        pass
            except Exception:
                continue