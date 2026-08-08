from enum import Enum
from dataclasses import dataclass


class Collections(Enum):
    USERS = "users"
    ROBOTS = "robots"
    MEDICINES = "medicines"
    EMERGENCIES = "emergencies"
    CAREGIVERS = "caregivers"
    NOTIFICATIONS = "notifications"


@dataclass(frozen=True)
class FirestorePaths:
    def user(self, user_id: str) -> str:
        return f"users/{user_id}"

    def robot(self, robot_id: str) -> str:
        return f"robots/{robot_id}"

    def medicine(self, user_id: str, medicine_id: str) -> str:
        return f"users/{user_id}/medicines/{medicine_id}"

    def emergency(self, emergency_id: str) -> str:
        return f"emergencies/{emergency_id}"

    def caregiver(self, caregiver_id: str) -> str:
        return f"caregivers/{caregiver_id}"

    def notification(self, notification_id: str) -> str:
        return f"notifications/{notification_id}"