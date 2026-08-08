import logging
import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from firebase_admin import auth as firebase_auth
from app.websocket.manager import ConnectionManager

logger = logging.getLogger(__name__)

router = APIRouter()
manager = ConnectionManager()


def authenticate_ws_token(token: str) -> str:
    """Authenticate a WebSocket token. Returns user_id or raises ValueError."""
    if not token:
        raise ValueError("Missing authentication token")
    # Test token support (same pattern as REST auth)
    if token.startswith("test-token-"):
        return token.replace("test-token-", "")
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return decoded_token["uid"]
    except Exception as e:
        raise ValueError(f"Invalid authentication token: {str(e)}")


@router.websocket("/ws/dashboard")
async def websocket_dashboard(websocket: WebSocket):
    """Authenticated WebSocket endpoint for real-time user dashboard events.

    Connection protocol:
    1. Client connects to /ws/dashboard
    2. Client sends JSON: {"type": "auth", "token": "<firebase_id_token>"}
    3. Server responds: {"type": "auth_success", "user_id": "..."}
    4. Server streams events: telemetry, location, emergency, medication updates
    """
    # Accept connection first, then authenticate via message
    await websocket.accept()

    user_id = None
    try:
        # Wait for auth message (5 second timeout)
        import asyncio
        try:
            raw = await asyncio.wait_for(websocket.receive_text(), timeout=5.0)
        except asyncio.TimeoutError:
            await websocket.send_text(json.dumps({"type": "error", "message": "Authentication timeout"}))
            await websocket.close(code=4001)
            return

        try:
            auth_msg = json.loads(raw)
        except json.JSONDecodeError:
            await websocket.send_text(json.dumps({"type": "error", "message": "Invalid JSON"}))
            await websocket.close(code=4002)
            return

        if auth_msg.get("type") != "auth" or not auth_msg.get("token"):
            await websocket.send_text(json.dumps({"type": "error", "message": "Expected auth message with token"}))
            await websocket.close(code=4003)
            return

        try:
            user_id = authenticate_ws_token(auth_msg["token"])
        except ValueError as e:
            await websocket.send_text(json.dumps({"type": "error", "message": str(e)}))
            await websocket.close(code=4004)
            return

        # Register with manager (re-accept not needed since we accepted above)
        manager.register(user_id, websocket)

        await websocket.send_text(json.dumps({"type": "auth_success", "user_id": user_id}))
        logger.info(f"WebSocket authenticated for user {user_id}")

        # Keep connection alive, listen for client messages
        while True:
            try:
                data = await websocket.receive_text()
                # Client can send ping/pong or request events
                try:
                    msg = json.loads(data)
                    if msg.get("type") == "ping":
                        await websocket.send_text(json.dumps({"type": "pong"}))
                except json.JSONDecodeError:
                    pass
            except WebSocketDisconnect:
                break

    except WebSocketDisconnect:
        pass
    except Exception as e:
        logger.error(f"WebSocket error for user {user_id}: {e}")
    finally:
        if user_id:
            await manager.disconnect(user_id, websocket)
