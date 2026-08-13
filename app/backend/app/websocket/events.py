import logging
from app.websocket.manager import ConnectionManager

logger = logging.getLogger(__name__)

manager = ConnectionManager()


def broadcast_telemetry(user_id: str, robot_id: str, telemetry_data: dict) -> None:
    """Broadcast robot telemetry update to the owning user's WebSocket connections."""
    event = {
        "type": "telemetry",
        "robot_id": robot_id,
        "data": telemetry_data,
    }
    manager.broadcast_sync(user_id, event)


def broadcast_location(user_id: str, robot_id: str, location_data: dict) -> None:
    """Broadcast robot location/waypoint update to the owning user."""
    event = {
        "type": "location",
        "robot_id": robot_id,
        "data": location_data,
    }
    manager.broadcast_sync(user_id, event)


def broadcast_emergency(user_id: str, emergency_data: dict) -> None:
    """Broadcast emergency alert to the owning user."""
    event = {
        "type": "emergency",
        "data": emergency_data,
    }
    manager.broadcast_sync(user_id, event)


def broadcast_medication(user_id: str, medication_data: dict) -> None:
    """Broadcast medication status update to the owning user."""
    event = {
        "type": "medication",
        "data": medication_data,
    }
    manager.broadcast_sync(user_id, event)


def broadcast_heartbeat(user_id: str, robot_id: str, status_data: dict) -> None:
    """Broadcast robot heartbeat/status change to the owning user."""
    event = {
        "type": "heartbeat",
        "robot_id": robot_id,
        "data": status_data,
    }
    manager.broadcast_sync(user_id, event)


def broadcast_notification(recipient_id: str, notification_data: dict) -> None:
    """Broadcast notification to the recipient user's active WebSocket connections."""
    event = {
        "type": "notification",
        "data": notification_data,
    }
    manager.broadcast_sync(recipient_id, event)
