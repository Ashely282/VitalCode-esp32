from enum import Enum


class Topics(Enum):
    STATUS = "vitalcode/robots/{robot_id}/status"
    COMMAND = "vitalcode/robots/{robot_id}/command"
    MEDICINE = "vitalcode/robots/{robot_id}/medicine"
    EMERGENCY = "vitalcode/robots/{robot_id}/emergency"
    HEARTBEAT = "vitalcode/robots/{robot_id}/heartbeat"
    TELEMETRY = "vitalcode/robots/{robot_id}/telemetry"
    RESPONSE = "vitalcode/robots/{robot_id}/response"

    def format(self, robot_id: str) -> str:
        return self.value.format(robot_id=robot_id)