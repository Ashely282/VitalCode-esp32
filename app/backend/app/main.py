import logging
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends
from app.routes.user import router as user_router
from app.routes.robot import router as robot_router
from app.routes.medicine import router as medicine_router
from app.routes.emergency import router as emergency_router
from app.routes.caregiver import router as caregiver_router
from app.routes.notification import router as notification_router
from app.websocket.routes import router as ws_router
from app.middleware.auth import get_current_user_uid

logger = logging.getLogger(__name__)


async def scheduled_medicine_runner():
    """Background loop that periodically executes the medicine scheduler and robot heartbeat monitor."""
    from app.services.medicine_service import MedicineService
    from app.services.robot_service import RobotService
    med_service = MedicineService()
    robot_service = RobotService()
    logger.info("Starting background scheduled runner.")
    while True:
        try:
            # Firestore calls are synchronous, run in thread pool to avoid blocking the event loop
            await asyncio.to_thread(med_service.process_scheduled_medicines)
            await asyncio.to_thread(robot_service.process_robot_heartbeats)
        except asyncio.CancelledError:
            logger.info("Background scheduled runner cancelled.")
            break
        except Exception as e:
            logger.error(f"Error in background scheduled runner: {e}")
        await asyncio.sleep(5)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: safe MQTT initialization
    try:
        from app.mqtt.client import MQTTClient
        from app.mqtt.mqtt_service import MQTTService

        mqtt_client = MQTTClient()
        mqtt_client.connect()
        MQTTService.setup_subscriptions()
        logger.info("MQTT client initialized successfully.")
    except Exception as e:
        logger.warning(f"MQTT initialization failed ({e}). Application continues without MQTT.")

    # Start the automated medicine scheduler
    runner_task = asyncio.create_task(scheduled_medicine_runner())

    yield

    # Shutdown: cancel task & clean MQTT disconnect
    runner_task.cancel()
    try:
        await runner_task
    except asyncio.CancelledError:
        pass

    try:
        from app.mqtt.client import MQTTClient
        mqtt_client = MQTTClient()
        mqtt_client.disconnect()
        logger.info("MQTT client disconnected.")
    except Exception:
        pass


app = FastAPI(
    title="VITALCODE Backend",
    version="1.0.0",
    lifespan=lifespan
)

auth_dependency = [Depends(get_current_user_uid)]

app.include_router(user_router, prefix="/api/v1", dependencies=auth_dependency)
app.include_router(robot_router, prefix="/api/v1", dependencies=auth_dependency)
app.include_router(medicine_router, prefix="/api/v1", dependencies=auth_dependency)
app.include_router(emergency_router, prefix="/api/v1", dependencies=auth_dependency)
app.include_router(caregiver_router, prefix="/api/v1", dependencies=auth_dependency)
app.include_router(notification_router, prefix="/api/v1", dependencies=auth_dependency)

# WebSocket router — auth handled within the WS endpoint via token exchange
app.include_router(ws_router)


@app.get("/health")
async def health():
    return {"status": "ok"}