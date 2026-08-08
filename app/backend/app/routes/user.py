from fastapi import APIRouter, HTTPException, Depends
from app.schemas.user import UserCreate, UserUpdate
from app.services.user_service import UserService
from app.services.robot_service import RobotService
from app.services.medicine_service import MedicineService
from app.services.caregiver_service import CaregiverService
from app.services.emergency_service import EmergencyService
from app.services.notification_service import NotificationService
from app.middleware.auth import get_current_user_uid, verify_user_access

router = APIRouter(prefix="/users", tags=["Users"])
service = UserService()
robot_service = RobotService()
medicine_service = MedicineService()
caregiver_service = CaregiverService()
emergency_service = EmergencyService()
notification_service = NotificationService()


@router.post("/")
async def create_user(data: UserCreate, current_uid: str = Depends(get_current_user_uid)):
    created_user_id = service.create_user(data, user_id=current_uid)
    return {"id": created_user_id}


@router.get("/{user_id}")
async def get_user(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    user = service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return user


@router.put("/{user_id}")
async def update_user(user_id: str, data: UserUpdate, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    service.update_user(user_id, data)
    return {"message": "User updated successfully"}


@router.delete("/{user_id}")
async def delete_user(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    service.delete_user(user_id)
    return {"message": "Message deleted successfully"}


@router.get("/")
async def list_users(current_uid: str = Depends(get_current_user_uid)):
    users = service.list_users()
    return [u for u in users if u.get("id") == current_uid] or users


# Sub-resource endpoints
@router.get("/{user_id}/robots")
async def get_user_robots(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return robot_service.list_robots_by_user(user_id)


@router.get("/{user_id}/medicines")
async def get_user_medicines(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return medicine_service.list_medicines_by_patient(user_id)


@router.get("/{user_id}/caregivers")
async def get_user_caregivers(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return caregiver_service.list_caregivers_by_patient(user_id)


@router.get("/{user_id}/emergencies")
async def get_user_emergencies(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return emergency_service.list_emergencies_by_patient(user_id)


@router.get("/{user_id}/notifications")
async def get_user_notifications(user_id: str, current_uid: str = Depends(get_current_user_uid)):
    if not service.get_user(user_id):
        raise HTTPException(status_code=404, detail="User not found")
    verify_user_access(user_id, current_uid)
    return notification_service.list_notifications_by_recipient(user_id)