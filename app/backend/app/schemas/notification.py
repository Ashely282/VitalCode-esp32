from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime


class NotificationBase(BaseModel):
    title: str
    message: str
    recipient_id: str
    notification_type: Literal[
        "MEDICINE",
        "EMERGENCY",
        "SYSTEM",
        "REMINDER",
        "INFO"
    ]
    priority: Literal[
        "LOW",
        "NORMAL",
        "HIGH",
        "CRITICAL"
    ] = "NORMAL"
    is_read: bool = False


class NotificationCreate(NotificationBase):
    pass


class NotificationUpdate(BaseModel):
    title: Optional[str] = None
    message: Optional[str] = None
    recipient_id: Optional[str] = None
    notification_type: Optional[Literal[
        "MEDICINE",
        "EMERGENCY",
        "SYSTEM",
        "REMINDER",
        "INFO"
    ]] = None
    priority: Optional[Literal[
        "LOW",
        "NORMAL",
        "HIGH",
        "CRITICAL"
    ]] = None
    is_read: Optional[bool] = None


class NotificationResponse(NotificationBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True