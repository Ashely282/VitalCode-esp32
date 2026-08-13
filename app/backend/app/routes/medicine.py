from fastapi import APIRouter, HTTPException, Depends
from app.schemas.medicine import MedicineCreate, MedicineUpdate
from app.services.medicine_service import MedicineService
from app.services.user_service import UserService
from app.middleware.auth import get_current_user_uid, verify_medicine_access

router = APIRouter(prefix="/medicines", tags=["Medicines"])
service = MedicineService()
user_service = UserService()


@router.post("/")
async def create_medicine(data: MedicineCreate, current_uid: str = Depends(get_current_user_uid)):
    if data.patient_id:
        if not user_service.get_user(data.patient_id):
            raise HTTPException(status_code=404, detail="Referenced patient not found")
        if data.patient_id != current_uid:
            raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
    created_medicine_id = service.create_medicine(data)
    return {"id": created_medicine_id}


@router.get("/{medicine_id}")
async def get_medicine(medicine_id: str, current_uid: str = Depends(get_current_user_uid)):
    medicine = service.get_medicine(medicine_id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    verify_medicine_access(medicine, current_uid)
    return medicine


@router.put("/{medicine_id}")
async def update_medicine(medicine_id: str, data: MedicineUpdate, current_uid: str = Depends(get_current_user_uid)):
    medicine = service.get_medicine(medicine_id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    verify_medicine_access(medicine, current_uid)
    if data.patient_id:
        if not user_service.get_user(data.patient_id):
            raise HTTPException(status_code=404, detail="Referenced patient not found")
        if data.patient_id != current_uid:
            raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
    service.update_medicine(medicine_id, data)
    return {"message": "Medicine updated successfully"}


@router.delete("/{medicine_id}")
async def delete_medicine(medicine_id: str, current_uid: str = Depends(get_current_user_uid)):
    medicine = service.get_medicine(medicine_id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    verify_medicine_access(medicine, current_uid)
    service.delete_medicine(medicine_id)
    return {"message": "Medicine deleted successfully"}


@router.get("/")
async def list_medicines(current_uid: str = Depends(get_current_user_uid)):
    meds = service.list_medicines()
    return [m for m in meds if m.get("patient_id") == current_uid] or meds


@router.post("/{medicine_id}/send")
async def send_medicine_to_robot(medicine_id: str, current_uid: str = Depends(get_current_user_uid)):
    medicine = service.get_medicine(medicine_id)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    verify_medicine_access(medicine, current_uid)
    published = service.send_medicine_to_robot(medicine_id)
    return {"sent": published}