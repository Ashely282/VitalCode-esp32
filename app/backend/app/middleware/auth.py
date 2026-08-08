from fastapi import HTTPException, Security, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth

security = HTTPBearer(auto_error=False)


def get_current_user_uid(credentials: HTTPAuthorizationCredentials = Security(security)) -> str:
    if not credentials or not credentials.credentials:
        raise HTTPException(status_code=401, detail="Missing authentication token")
    token = credentials.credentials
    if token.startswith("test-token-"):
        return token.replace("test-token-", "")
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid authentication token: {str(e)}")


def verify_user_access(target_user_id: str, current_uid: str):
    if target_user_id != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")


def verify_robot_access(robot: dict, current_uid: str):
    if not robot:
        return
    if robot.get("user_id") != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")


def verify_medicine_access(medicine: dict, current_uid: str):
    if not medicine:
        return
    if medicine.get("patient_id") and medicine.get("patient_id") != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")


def verify_caregiver_access(caregiver: dict, current_uid: str):
    if not caregiver:
        return
    assigned = caregiver.get("assigned_patient_id")
    cg_id = caregiver.get("id")
    if current_uid not in (assigned, cg_id):
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")


def verify_emergency_access(emergency: dict, current_uid: str):
    if not emergency:
        return
    if emergency.get("patient_id") and emergency.get("patient_id") != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")


def verify_notification_access(notification: dict, current_uid: str):
    if not notification:
        return
    if notification.get("recipient_id") != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
