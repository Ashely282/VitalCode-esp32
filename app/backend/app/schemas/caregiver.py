from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class CaregiverBase(BaseModel):
    full_name: str
    email: EmailStr
    phone: str
    relationship: str
    assigned_patient_id: Optional[str] = None
    is_primary: bool = False


class CaregiverCreate(CaregiverBase):
    pass


class CaregiverUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    relationship: Optional[str] = None
    assigned_patient_id: Optional[str] = None
    is_primary: Optional[bool] = None


class CaregiverResponse(CaregiverBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True