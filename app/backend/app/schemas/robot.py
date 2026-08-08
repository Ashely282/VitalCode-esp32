from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class RobotBase(BaseModel):
    robot_id: str
    user_id: str
    device_name: str
    firmware_version: str
    wifi_connected: bool
    battery_percentage: int = Field(ge=0, le=100)
    status: str
    is_healthy: Optional[bool] = None
    last_heartbeat_at: Optional[datetime] = None
    offline_alert_sent: Optional[bool] = False
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    latest_waypoint: Optional[str] = None
    waypoint_status: Optional[str] = None
    location_history: Optional[list] = []


class RobotCreate(RobotBase):
    pass


class RobotUpdate(BaseModel):
    device_name: Optional[str] = None
    firmware_version: Optional[str] = None
    wifi_connected: Optional[bool] = None
    battery_percentage: Optional[int] = Field(default=None, ge=0, le=100)
    status: Optional[str] = None
    last_heartbeat_at: Optional[datetime] = None
    offline_alert_sent: Optional[bool] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    latest_waypoint: Optional[str] = None
    waypoint_status: Optional[str] = None
    location_history: Optional[list] = None


class RobotResponse(RobotBase):
    created_at: datetime
    updated_at: datetime