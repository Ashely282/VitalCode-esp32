from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime


class EmergencyBase(BaseModel):
    robot_id: str
    patient_id: Optional[str] = None
    alert_type: Literal[
        "FALL_DETECTED",
        "PANIC_BUTTON",
        "UNRESPONSIVE",
        "OBSTACLE_COLLISION",
        "LOW_BATTERY_CRITICAL"
    ]
    severity: Literal[
        "LOW",
        "MEDIUM",
        "HIGH",
        "CRITICAL"
    ]
    location: Optional[str] = None
    sensor_source: Optional[str] = None
    acknowledged: bool = False


class EmergencyCreate(EmergencyBase):
    pass


class EmergencyUpdate(BaseModel):
    robot_id: Optional[str] = None
    patient_id: Optional[str] = None
    alert_type: Optional[Literal[
        "FALL_DETECTED",
        "PANIC_BUTTON",
        "UNRESPONSIVE",
        "OBSTACLE_COLLISION",
        "LOW_BATTERY_CRITICAL"
    ]] = None
    severity: Optional[Literal[
        "LOW",
        "MEDIUM",
        "HIGH",
        "CRITICAL"
    ]] = None
    location: Optional[str] = None
    sensor_source: Optional[str] = None
    acknowledged: Optional[bool] = None


class EmergencyResponse(EmergencyBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True