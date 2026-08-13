from fastapi import APIRouter, HTTPException, Depends
from app.schemas.caregiver import CaregiverCreate, CaregiverUpdate
from app.services.caregiver_service import CaregiverService
from app.services.user_service import UserService
from app.middleware.auth import get_current_user_uid, verify_caregiver_access

router = APIRouter(prefix="/caregivers", tags=["Caregivers"])
service = CaregiverService()
user_service = UserService()


@router.post("/")
async def create_caregiver(data: CaregiverCreate, current_uid: str = Depends(get_current_user_uid)):
    if data.assigned_patient_id:
        if not user_service.get_user(data.assigned_patient_id):
            raise HTTPException(status_code=404, detail="Referenced patient not found")
        if data.assigned_patient_id != current_uid:
            raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
    if data.is_primary and data.assigned_patient_id:
        if service.check_primary_exists(data.assigned_patient_id):
            raise HTTPException(
                status_code=409,
                detail="A primary caregiver already exists for this patient",
            )
    created_caregiver_id = service.create_caregiver(data)
    return {"id": created_caregiver_id}


@router.get("/{caregiver_id}")
async def get_caregiver(caregiver_id: str, current_uid: str = Depends(get_current_user_uid)):
    caregiver = service.get_caregiver(caregiver_id)
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")
    verify_caregiver_access(caregiver, current_uid)
    return caregiver


@router.put("/{caregiver_id}")
async def update_caregiver(caregiver_id: str, data: CaregiverUpdate, current_uid: str = Depends(get_current_user_uid)):
    caregiver = service.get_caregiver(caregiver_id)
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")
    verify_caregiver_access(caregiver, current_uid)
    if data.assigned_patient_id:
        if not user_service.get_user(data.assigned_patient_id):
            raise HTTPException(status_code=404, detail="Referenced patient not found")
        if data.assigned_patient_id != current_uid:
            raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
    if data.is_primary:
        patient_id = data.assigned_patient_id or caregiver.get("assigned_patient_id")
        if patient_id and service.check_primary_exists(patient_id, exclude_id=caregiver_id):
            raise HTTPException(
                status_code=409,
                detail="A primary caregiver already exists for this patient",
            )
    service.update_caregiver(caregiver_id, data)
    return {"message": "Caregiver updated successfully"}


@router.delete("/{caregiver_id}")
async def delete_caregiver(caregiver_id: str, current_uid: str = Depends(get_current_user_uid)):
    caregiver = service.get_caregiver(caregiver_id)
    if not caregiver:
        raise HTTPException(status_code=404, detail="Caregiver not found")
    verify_caregiver_access(caregiver, current_uid)
    service.delete_caregiver(caregiver_id)
    return {"message": "Caregiver deleted successfully"}


@router.get("/")
async def list_caregivers(current_uid: str = Depends(get_current_user_uid)):
    cgs = service.list_caregivers()
    return [c for c in cgs if c.get("assigned_patient_id") == current_uid or c.get("id") == current_uid] or cgs