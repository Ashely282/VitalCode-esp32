from datetime import datetime, timezone, timedelta
from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.emergency import EmergencyCreate, EmergencyUpdate
from app.websocket import events as ws_events

DUPLICATE_WINDOW_SECONDS = 120


class EmergencyService:
    def check_duplicate(self, robot_id: str, alert_type: str, severity: str, window_seconds: int = DUPLICATE_WINDOW_SECONDS):
        now = datetime.now(timezone.utc)
        docs = db.collection(Collections.EMERGENCIES.value).where("robot_id", "==", robot_id).stream()
        for doc in docs:
            data = doc.to_dict() or {}
            if data.get("alert_type") == alert_type and data.get("severity") == severity:
                created_at_val = data.get("created_at")
                if created_at_val:
                    try:
                        if isinstance(created_at_val, str):
                            dt = datetime.fromisoformat(created_at_val.replace("Z", "+00:00"))
                        elif isinstance(created_at_val, datetime):
                            dt = created_at_val
                        else:
                            continue
                        if dt.tzinfo is None:
                            dt = dt.replace(tzinfo=timezone.utc)
                        time_diff = (now - dt).total_seconds()
                        if 0 <= time_diff <= window_seconds:
                            return {"id": doc.id, **data}
                    except Exception:
                        continue
        return None

    def escalate_emergency(self, patient_id: str, alert_type: str, severity: str, location: str = None):
        if not patient_id or severity not in ("HIGH", "CRITICAL"):
            return

        docs = db.collection(Collections.CAREGIVERS.value).where("assigned_patient_id", "==", patient_id).stream()
        for doc in docs:
            cg_data = doc.to_dict() or {}
            if cg_data.get("is_primary") is True:
                notif_payload = {
                    "title": f"EMERGENCY ALERT: {alert_type}",
                    "message": f"Emergency alert ({alert_type}, severity: {severity}) for patient {patient_id}" + (f" at {location}" if location else ""),
                    "recipient_id": doc.id,
                    "notification_type": "EMERGENCY",
                    "priority": "CRITICAL" if severity == "CRITICAL" else "HIGH",
                    "is_read": False,
                    "created_at": datetime.now(timezone.utc).isoformat(),
                }
                notif_ref = db.collection(Collections.NOTIFICATIONS.value).document()
                notif_ref.set(notif_payload)
                try:
                    ws_events.broadcast_notification(doc.id, {**notif_payload, "id": notif_ref.id})
                except Exception:
                    pass

    def process_emergency(self, payload: dict) -> dict:
        robot_id = payload.get("robot_id")
        alert_type = payload.get("alert_type")
        severity = payload.get("severity")
        patient_id = payload.get("patient_id")
        location = payload.get("location")

        # 1. Duplicate check
        duplicate = self.check_duplicate(robot_id, alert_type, severity)
        if duplicate:
            return {"id": duplicate["id"]}

        # 2. Create emergency document
        if "created_at" not in payload:
            payload["created_at"] = datetime.now(timezone.utc).isoformat()

        doc_ref = db.collection(Collections.EMERGENCIES.value).document()
        doc_ref.set(payload)
        emergency_id = doc_ref.id

        # 3. Escalation check
        self.escalate_emergency(patient_id, alert_type, severity, location)

        # 3b. WebSocket real-time alert to patient
        if patient_id:
            ws_events.broadcast_emergency(patient_id, {
                "emergency_id": emergency_id,
                "alert_type": alert_type,
                "severity": severity,
                "location": location,
                "robot_id": robot_id,
                "created_at": payload.get("created_at"),
            })

        # 4. MQTT emergency command (non-blocking, failure-safe)
        try:
            from app.mqtt.mqtt_service import MQTTService
            # Resolve robot_id field to publish to the right topic
            robot_doc = db.collection(Collections.ROBOTS.value).document(robot_id).get()
            mqtt_robot_id = robot_id
            if robot_doc.exists:
                mqtt_robot_id = robot_doc.to_dict().get("robot_id", robot_id)
            MQTTService.publish_emergency_command(mqtt_robot_id, payload)
        except Exception:
            pass  # MQTT failure must not prevent emergency creation

        return {"id": emergency_id}

    def create_emergency(self, data: EmergencyCreate) -> str:
        payload = data.model_dump(exclude_unset=True)
        res = self.process_emergency(payload)
        return res["id"]

    def _create_emergency_with_payload(self, payload: dict) -> str:
        res = self.process_emergency(payload)
        return res["id"]

    def get_emergency(self, emergency_id: str):
        doc = db.collection(Collections.EMERGENCIES.value).document(emergency_id).get()

        if not doc.exists:
            return None

        return {
            "id": doc.id,
            **doc.to_dict(),
        }

    def update_emergency(self, emergency_id: str, data: EmergencyUpdate) -> None:
        db.collection(Collections.EMERGENCIES.value).document(emergency_id).update(data.model_dump(exclude_unset=True))

    def delete_emergency(self, emergency_id: str) -> None:
        db.collection(Collections.EMERGENCIES.value).document(emergency_id).delete()

    def list_emergencies(self):
        docs = db.collection(Collections.EMERGENCIES.value).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def list_emergencies_by_patient(self, patient_id: str):
        docs = db.collection(Collections.EMERGENCIES.value).where("patient_id", "==", patient_id).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def list_emergencies_by_robot(self, robot_id: str):
        docs = db.collection(Collections.EMERGENCIES.value).where("robot_id", "==", robot_id).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]