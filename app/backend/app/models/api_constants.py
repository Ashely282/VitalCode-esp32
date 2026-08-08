from enum import Enum


class API(Enum):
    VERSION = "/api/v1"


class Routes(Enum):
    USERS = "/users"
    ROBOTS = "/robots"
    MEDICINES = "/medicines"
    EMERGENCIES = "/emergencies"
    CAREGIVERS = "/caregivers"
    NOTIFICATIONS = "/notifications"


class ResponseStatus(Enum):
    SUCCESS = "success"
    ERROR = "error"


class RobotStatus(Enum):
    ONLINE = "online"
    OFFLINE = "offline"
    IDLE = "idle"
    MOVING = "moving"
    CHARGING = "charging"
    EMERGENCY = "emergency"