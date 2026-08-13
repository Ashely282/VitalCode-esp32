from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class MedicineBase(BaseModel):
    patient_id: Optional[str] = None
    medicine_name: str
    dosage: str
    instructions: Optional[str] = None
    scheduled_time: datetime
    requires_confirmation: bool = True
    retry_count: int = Field(default=0, ge=0)
    status: str = "PENDING"
    last_sent_at: Optional[datetime] = None


class MedicineCreate(MedicineBase):
    pass


class MedicineUpdate(BaseModel):
    patient_id: Optional[str] = None
    medicine_name: Optional[str] = None
    dosage: Optional[str] = None
    instructions: Optional[str] = None
    scheduled_time: Optional[datetime] = None
    requires_confirmation: Optional[bool] = None
    retry_count: Optional[int] = Field(default=None, ge=0)
    status: Optional[str] = None
    last_sent_at: Optional[datetime] = None


class MedicineResponse(MedicineBase):
    id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True