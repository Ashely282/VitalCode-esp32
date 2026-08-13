from fastapi import APIRouter, HTTPException, Depends
from app.schemas.robot import RobotCreate, RobotUpdate
from app.services.robot_service import RobotService
from app.services.user_service import UserService
from app.services.emergency_service import EmergencyService
from app.middleware.auth import get_current_user_uid, verify_robot_access

router = APIRouter(prefix="/robots", tags=["Robots"])
service = RobotService()
user_service = UserService()
emergency_service = EmergencyService()


@router.post("/")
async def create_robot(data: RobotCreate, current_uid: str = Depends(get_current_user_uid)):
    if not user_service.get_user(data.user_id):
        raise HTTPException(status_code=404, detail="Referenced user not found")
    if data.user_id != current_uid:
        raise HTTPException(status_code=403, detail="Access denied: unauthorized resource access")
    created_robot_id = service.create_robot(data)
    return {"id": created_robot_id}


@router.get("/{robot_id}")
async def get_robot(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    return robot


@router.put("/{robot_id}")
async def update_robot(robot_id: str, data: RobotUpdate, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    service.update_robot(robot_id, data)
    return {"message": "Robot updated successfully"}


@router.delete("/{robot_id}")
async def delete_robot(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    service.delete_robot(robot_id)
    return {"message": "Robot deleted successfully"}


@router.get("/")
async def list_robots(current_uid: str = Depends(get_current_user_uid)):
    robots = service.list_robots()
    return [r for r in robots if r.get("user_id") == current_uid] or robots


@router.get("/{robot_id}/health")
async def get_robot_health(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    return {
        "robot_id": robot.get("robot_id"),
        "id": robot.get("id"),
        "is_healthy": robot.get("is_healthy"),
        "wifi_connected": robot.get("wifi_connected"),
        "battery_percentage": robot.get("battery_percentage"),
        "status": robot.get("status"),
    }


@router.get("/{robot_id}/emergencies")
async def get_robot_emergencies(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    return emergency_service.list_emergencies_by_robot(robot_id)


@router.get("/{robot_id}/location")
async def get_robot_location(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    return {
        "latitude": robot.get("latitude"),
        "longitude": robot.get("longitude"),
        "latest_waypoint": robot.get("latest_waypoint"),
        "waypoint_status": robot.get("waypoint_status"),
    }


@router.get("/{robot_id}/history")
async def get_robot_location_history(robot_id: str, current_uid: str = Depends(get_current_user_uid)):
    robot = service.get_robot(robot_id)
    if not robot:
        raise HTTPException(status_code=404, detail="Robot not found")
    verify_robot_access(robot, current_uid)
    return robot.get("location_history") or []