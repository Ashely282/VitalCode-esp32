import logging
from typing import Optional
from app.mqtt.publisher import MQTTPublisher
from app.mqtt.subscriber import MQTTSubscriber
from app.mqtt.topics import Topics
from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.websocket import events as ws_events

logger = logging.getLogger(__name__)

publisher = MQTTPublisher()
subscriber = MQTTSubscriber()


class MQTTService:
    """Service layer for all MQTT robot communication."""

    # ── Telemetry Ingestion ──────────────────────────────────

    @staticmethod
    def handle_telemetry(topic: str, payload) -> None:
        """Callback for robot telemetry messages.
        Parses the payload, resolves the robot, and updates state in Firestore.
        """
        if not isinstance(payload, dict):
            logger.warning(f"Malformed telemetry payload (not dict): {payload}")
            return

        robot_id_from_topic = MQTTService._extract_robot_id(topic)
        robot_id_field = payload.get("robot_id", robot_id_from_topic)

        if not robot_id_field:
            logger.warning("Telemetry payload missing robot_id and cannot resolve from topic.")
            return

        # Resolve robot by robot_id field value (the logical robot identifier)
        robot_doc = MQTTService._resolve_robot(robot_id_field)
        if not robot_doc:
            logger.warning(f"Unknown robot in telemetry: {robot_id_field}")
            return

        doc_id = robot_doc["id"]
        update_fields = MQTTService._extract_telemetry_fields(payload)

        # Heartbeat monitoring updates: any telemetry/heartbeat received shows the robot is online
        from datetime import datetime, timezone
        now_dt = datetime.now(timezone.utc)
        update_fields["last_heartbeat_at"] = now_dt.isoformat()
        update_fields["offline_alert_sent"] = False
        update_fields["wifi_connected"] = True

        # Log location history if coordinates are updated
        if "latitude" in update_fields and "longitude" in update_fields:
            history = robot_doc.get("location_history") or []
            if not isinstance(history, list):
                history = []

            history_item = {
                "latitude": update_fields["latitude"],
                "longitude": update_fields["longitude"],
                "timestamp": now_dt.isoformat(),
                "waypoint": update_fields.get("latest_waypoint", robot_doc.get("latest_waypoint")),
                "status": update_fields.get("waypoint_status", robot_doc.get("waypoint_status"))
            }
            history.append(history_item)
            update_fields["location_history"] = history

        # Trigger obstacle alert if waypoint_status is OBSTACLE
        if update_fields.get("waypoint_status") == "OBSTACLE":
            from app.services.emergency_service import EmergencyService
            emergency_payload = {
                "robot_id": doc_id,
                "patient_id": robot_doc.get("user_id"),
                "alert_type": "OBSTACLE_COLLISION",
                "severity": "HIGH",
                "sensor_source": "NAVIGATION_SYSTEM",
                "acknowledged": False,
                "location": update_fields.get("latest_waypoint", "Unknown"),
                "created_at": now_dt.isoformat()
            }
            try:
                EmergencyService().process_emergency(emergency_payload)
            except Exception as e:
                logger.error(f"Failed to create obstacle emergency: {e}")

        try:
            db.collection(Collections.ROBOTS.value).document(doc_id).update(update_fields)
            logger.info(f"Updated robot {doc_id} telemetry & heartbeat: {list(update_fields.keys())}")

            # ── WebSocket broadcasts ─────────────────────────────
            owner_uid = robot_doc.get("user_id")
            if owner_uid:
                # Telemetry event (battery, status, wifi, firmware)
                telemetry_subset = {k: v for k, v in update_fields.items()
                                    if k in ("battery_percentage", "wifi_connected",
                                             "status", "firmware_version", "device_name")}
                if telemetry_subset:
                    ws_events.broadcast_telemetry(owner_uid, doc_id, telemetry_subset)

                # Location event
                if "latitude" in update_fields and "longitude" in update_fields:
                    loc_data = {
                        "latitude": update_fields["latitude"],
                        "longitude": update_fields["longitude"],
                        "waypoint": update_fields.get("latest_waypoint"),
                        "waypoint_status": update_fields.get("waypoint_status"),
                    }
                    ws_events.broadcast_location(owner_uid, doc_id, loc_data)

                # Heartbeat / online recovery event
                ws_events.broadcast_heartbeat(owner_uid, doc_id, {
                    "status": "ONLINE",
                    "last_heartbeat_at": update_fields.get("last_heartbeat_at"),
                })
        except Exception as e:
            logger.error(f"Failed to update robot {doc_id} telemetry & heartbeat: {e}")

    @staticmethod
    def _extract_robot_id(topic: str) -> Optional[str]:
        """Extract robot_id from topic pattern vitalcode/robots/{robot_id}/telemetry."""
        parts = topic.split("/")
        if len(parts) >= 3 and parts[0] == "vitalcode" and parts[1] == "robots":
            return parts[2]
        return None

    @staticmethod
    def _resolve_robot(robot_id_field: str) -> Optional[dict]:
        """Resolve a robot document by robot_id field (not Firestore doc ID)."""
        docs = db.collection(Collections.ROBOTS.value).where("robot_id", "==", robot_id_field).stream()
        for doc in docs:
            return {"id": doc.id, **doc.to_dict()}
        return None

    @staticmethod
    def _extract_telemetry_fields(payload: dict) -> dict:
        """Extract valid telemetry fields from payload for robot update."""
        allowed = {
            "wifi_connected": bool,
            "battery_percentage": int,
            "status": str,
            "firmware_version": str,
            "device_name": str,
            "latitude": (int, float),
            "longitude": (int, float),
            "latest_waypoint": str,
            "waypoint_status": str,
        }
        fields = {}
        for key, expected_type in allowed.items():
            if key in payload:
                val = payload[key]
                if isinstance(val, expected_type) and not isinstance(val, bool):
                    if key == "battery_percentage" and not (0 <= val <= 100):
                        continue
                    fields[key] = val

        # Validate coordinate ranges
        has_lat = "latitude" in fields
        has_lon = "longitude" in fields
        if has_lat or has_lon:
            if not (has_lat and has_lon):
                # Discard if only one coordinate is present
                fields.pop("latitude", None)
                fields.pop("longitude", None)
            else:
                lat = fields["latitude"]
                lon = fields["longitude"]
                if not (-90.0 <= lat <= 90.0) or not (-180.0 <= lon <= 180.0):
                    # Discard if either is outside acceptable bounds
                    fields.pop("latitude", None)
                    fields.pop("longitude", None)
        return fields

    # ── Telemetry Parsing (standalone, for testing) ──────────

    @staticmethod
    def parse_telemetry(payload: dict) -> Optional[dict]:
        """Validate and parse a telemetry payload. Returns extracted fields or None."""
        if not isinstance(payload, dict):
            return None
        robot_id = payload.get("robot_id")
        if not robot_id:
            return None
        fields = MQTTService._extract_telemetry_fields(payload)
        return {"robot_id": robot_id, **fields} if fields else None

    # ── Robot Command Publishing ─────────────────────────────

    @staticmethod
    def publish_robot_command(robot_id: str, command_payload: dict) -> bool:
        """Publish a generic command to a specific robot."""
        topic = Topics.COMMAND.format(robot_id)
        return publisher.publish(topic, command_payload)

    @staticmethod
    def publish_emergency_command(robot_id: str, emergency_data: dict) -> bool:
        """Publish an emergency command to a specific robot."""
        topic = Topics.EMERGENCY.format(robot_id)
        payload = {
            "command": "EMERGENCY",
            "alert_type": emergency_data.get("alert_type"),
            "severity": emergency_data.get("severity"),
            "patient_id": emergency_data.get("patient_id"),
            "location": emergency_data.get("location"),
        }
        return publisher.publish(topic, payload)

    @staticmethod
    def publish_medicine_command(robot_id: str, medicine_data: dict) -> bool:
        """Publish a medication reminder/delivery command to a specific robot."""
        topic = Topics.MEDICINE.format(robot_id)
        payload = {
            "command": "MEDICATION_REMINDER",
            "medicine_id": medicine_data.get("id"),
            "medicine_name": medicine_data.get("medicine_name"),
            "dosage": medicine_data.get("dosage"),
            "instructions": medicine_data.get("instructions"),
            "patient_id": medicine_data.get("patient_id"),
        }
        return publisher.publish(topic, payload)

    # ── Response Handlers ─────────────────────────────────────

    @staticmethod
    def handle_response(topic: str, payload) -> None:
        """Callback for robot response messages (command confirmations)."""
        if not isinstance(payload, dict):
            logger.warning(f"Malformed response payload: {payload}")
            return

        command = payload.get("command")
        if command == "MEDICATION_REMINDER":
            med_id = payload.get("medicine_id")
            status = payload.get("status")
            if med_id and status in ("CONFIRMED", "TAKEN"):
                try:
                    db.collection(Collections.MEDICINES.value).document(med_id).update({
                        "status": "CONFIRMED"
                    })
                    logger.info(f"Medicine {med_id} confirmed/taken via robot response.")

                    # Broadcast medication confirmation via WebSocket
                    med_doc = db.collection(Collections.MEDICINES.value).document(med_id).get()
                    if med_doc.exists:
                        med_data = med_doc.to_dict() or {}
                        owner = med_data.get("patient_id")
                        if owner:
                            ws_events.broadcast_medication(owner, {
                                "medicine_id": med_id,
                                "status": "CONFIRMED",
                                "medicine_name": med_data.get("medicine_name"),
                            })
                except Exception as e:
                    logger.error(f"Failed to update medicine {med_id} status on robot response: {e}")

    # ── Subscription Setup ───────────────────────────────────

    @staticmethod
    def setup_subscriptions() -> None:
        """Register MQTT subscriptions for robot telemetry, heartbeat, and responses."""
        telemetry_topic = "vitalcode/robots/+/telemetry"
        heartbeat_topic = "vitalcode/robots/+/heartbeat"
        response_topic = "vitalcode/robots/+/response"

        subscriber.subscribe(telemetry_topic, MQTTService.handle_telemetry)
        subscriber.subscribe(heartbeat_topic, MQTTService.handle_telemetry)
        subscriber.subscribe(response_topic, MQTTService.handle_response)
        logger.info("MQTT subscriptions established for telemetry, heartbeat, and response.")
