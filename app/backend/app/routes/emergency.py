from fastapi import APIRouter, HTTPException, Depends
from app.schemas.emergency import EmergencyCreate, EmergencyUpdate
from app.services.emergency_service import EmergencyService
from app.services.robot_service import RobotService
from app.services.user_service import UserService
from app.middleware.auth import get_current_user_uid, verify_emergency_access

router = APIRouter(prefix="/emergencies", tags=["Emergencies"])
service = EmergencyService()
robot_service = RobotService()
user_service = UserService()


@router.post("/")
async def create_emergency(data: EmergencyCreate, current_uid: str = Depends(get_current_user_uid)):
    robot = robot_service.get_robot(data.robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Referenced robot not found")

    patient_id = data.patient_id
    if not patient_id:
        patient_id = robot.get("user_id")

    if patient_id and not user_service.get_user(patient_id):
        raise HTTPException(status_code=404, detail="Referenced patient not found")

    if patient_id != current_uid and robot.get("user_id") != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")

    payload = data.model_dump(exclude_unset=True)
    if not data.patient_id and patient_id:
        payload["patient_id"] = patient_id

    result = service.process_emergency(payload)
    return result


@router.get("/{emergency_id}")
async def get_emergency(emergency_id: str, current_uid: str = Depends(get_current_user_uid)):
    emergency = service.get_emergency(emergency_id)
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")
    verify_emergency_access(emergency, current_uid)
    return emergency


@router.put("/{emergency_id}")
async def update_emergency(emergency_id: str, data: EmergencyUpdate, current_uid: str = Depends(get_current_user_uid)):
    emergency = service.get_emergency(emergency_id)
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")
    verify_emergency_access(emergency, current_uid)
    service.update_emergency(emergency_id, data)
    return {"message": "Emergency updated successfully"}


@router.delete("/{emergency_id}")
async def delete_emergency(emergency_id: str, current_uid: str = Depends(get_current_user_uid)):
    emergency = service.get_emergency(emergency_id)
    if not emergency:
        raise HTTPException(status_code=404, detail="Emergency not found")
    verify_emergency_access(emergency, current_uid)
    service.delete_emergency(emergency_id)
    return {"message": "Emergency deleted successfully"}


@router.get("/")
async def list_emergencies(current_uid: str = Depends(get_current_user_uid)):
    ems = service.list_emergencies()
    return [e for e in ems if e.get("patient_id") == current_uid] or ems