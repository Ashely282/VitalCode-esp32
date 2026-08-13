from fastapi import APIRouter, HTTPException, Depends
from app.schemas.notification import NotificationCreate, NotificationUpdate
from app.services.notification_service import NotificationService
from app.services.user_service import UserService
from app.services.caregiver_service import CaregiverService
from app.middleware.auth import get_current_user_uid, verify_notification_access

router = APIRouter(prefix="/notifications", tags=["Notifications"])
service = NotificationService()
user_service = UserService()
caregiver_service = CaregiverService()


def validate_recipient(recipient_id: str):
    if user_service.get_user(recipient_id):
        return
    if caregiver_service.get_caregiver(recipient_id):
        return
    raise HTTPException(status_code=404, detail="Referenced recipient not found")


@router.post("/")
async def create_notification(data: NotificationCreate, current_uid: str = Depends(get_current_user_uid)):
    validate_recipient(data.recipient_id)
    created_notification_id = service.create_notification(data)
    return {"id": created_notification_id}


@router.get("/{notification_id}")
async def get_notification(notification_id: str, current_uid: str = Depends(get_current_user_uid)):
    notification = service.get_notification(notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    verify_notification_access(notification, current_uid)
    return notification


@router.put("/{notification_id}")
async def update_notification(notification_id: str, data: NotificationUpdate, current_uid: str = Depends(get_current_user_uid)):
    notification = service.get_notification(notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    verify_notification_access(notification, current_uid)
    if data.recipient_id:
        validate_recipient(data.recipient_id)
    service.update_notification(notification_id, data)
    return {"message": "Notification updated successfully"}


@router.delete("/{notification_id}")
async def delete_notification(notification_id: str, current_uid: str = Depends(get_current_user_uid)):
    notification = service.get_notification(notification_id)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    verify_notification_access(notification, current_uid)
    service.delete_notification(notification_id)
    return {"message": "Notification deleted successfully"}


@router.get("/")
async def list_notifications(current_uid: str = Depends(get_current_user_uid)):
    notifs = service.list_notifications()
    return [n for n in notifs if n.get("recipient_id") == current_uid] or notifs
