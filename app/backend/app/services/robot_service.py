from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.robot import RobotCreate, RobotUpdate
from app.websocket import events as ws_events


class RobotService:
    def _compute_health(self, data: dict) -> dict:
        wifi = bool(data.get("wifi_connected", False))
        battery = int(data.get("battery_percentage", 0))
        is_healthy = wifi and (battery >= 15)
        return {
            **data,
            "is_healthy": is_healthy
        }

    def create_robot(self, data: RobotCreate) -> str:
        from datetime import datetime, timezone
        doc_ref = db.collection(Collections.ROBOTS.value).document()
        payload = data.model_dump(exclude_unset=True)
        if "last_heartbeat_at" not in payload:
            payload["last_heartbeat_at"] = datetime.now(timezone.utc).isoformat()
        if "offline_alert_sent" not in payload:
            payload["offline_alert_sent"] = False
        doc_ref.set(payload)
        return doc_ref.id

    def process_robot_heartbeats(self) -> None:
        """Scan all robots and mark those as offline if they haven't sent a heartbeat for > 60 seconds."""
        from datetime import datetime, timezone
        from app.services.emergency_service import EmergencyService

        now = datetime.now(timezone.utc)
        docs = db.collection(Collections.ROBOTS.value).stream()
        for doc in docs:
            data = doc.to_dict() or {}
            last_hb_val = data.get("last_heartbeat_at")
            if not last_hb_val:
                continue

            try:
                if isinstance(last_hb_val, str):
                    dt = datetime.fromisoformat(last_hb_val.replace("Z", "+00:00"))
                elif isinstance(last_hb_val, datetime):
                    dt = last_hb_val
                else:
                    continue
                if dt.tzinfo is None:
                    dt = dt.replace(tzinfo=timezone.utc)

                diff_seconds = (now - dt).total_seconds()
                # Threshold of 60 seconds
                if diff_seconds > 60:
                    update_data = {}

                    # Mark connectivity offline
                    if data.get("wifi_connected") is not False or data.get("status") != "OFFLINE":
                        update_data["wifi_connected"] = False
                        update_data["status"] = "OFFLINE"

                    # Trigger alert if not already sent
                    if not data.get("offline_alert_sent", False):
                        update_data["offline_alert_sent"] = True

                        # Create emergency
                        emergency_payload = {
                            "robot_id": doc.id,
                            "patient_id": data.get("user_id"),
                            "alert_type": "UNRESPONSIVE",
                            "severity": "HIGH",
                            "sensor_source": "HEARTBEAT_MONITOR",
                            "acknowledged": False,
                            "location": "Home",
                            "created_at": now.isoformat()
                        }
                        try:
                            # Use emergency service to process and automatically escalate
                            EmergencyService().process_emergency(emergency_payload)
                        except Exception:
                            pass

                    if update_data:
                        db.collection(Collections.ROBOTS.value).document(doc.id).update(update_data)

                        # WebSocket: broadcast offline status to owning user
                        owner_uid = data.get("user_id")
                        if owner_uid:
                            ws_events.broadcast_heartbeat(owner_uid, doc.id, {
                                "status": "OFFLINE",
                                "last_heartbeat_at": last_hb_val if isinstance(last_hb_val, str) else str(last_hb_val),
                            })
            except Exception:
                continue

    def get_robot(self, robot_id: str):
        doc = db.collection(Collections.ROBOTS.value).document(robot_id).get()

        if not doc.exists:
            return None

        data = {
            "id": doc.id,
            **doc.to_dict(),
        }
        return self._compute_health(data)

    def update_robot(self, robot_id: str, data: RobotUpdate) -> None:
        db.collection(Collections.ROBOTS.value).document(robot_id).update(data.model_dump(exclude_unset=True))

    def delete_robot(self, robot_id: str) -> None:
        db.collection(Collections.ROBOTS.value).document(robot_id).delete()

    def list_robots(self):
        docs = db.collection(Collections.ROBOTS.value).stream()
        return [
            self._compute_health({
                "id": doc.id,
                **doc.to_dict(),
            })
            for doc in docs
        ]

    def list_robots_by_user(self, user_id: str):
        docs = db.collection(Collections.ROBOTS.value).where("user_id", "==", user_id).stream()
        return [
            self._compute_health({
                "id": doc.id,
                **doc.to_dict(),
            })
            for doc in docs
        ]