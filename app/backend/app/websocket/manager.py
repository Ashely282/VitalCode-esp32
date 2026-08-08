import logging
import asyncio
import json
from typing import Dict, Set
from fastapi import WebSocket

logger = logging.getLogger(__name__)


class ConnectionManager:
    """Manages authenticated WebSocket connections grouped by user_id."""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._connections: Dict[str, Set[WebSocket]] = {}
        return cls._instance

    def register(self, user_id: str, websocket: WebSocket) -> None:
        """Register an already accepted websocket connection and capture loop."""
        if user_id not in self._connections:
            self._connections[user_id] = set()
        self._connections[user_id].add(websocket)
        self._loop = asyncio.get_running_loop()
        logger.info(f"WebSocket registered for user {user_id}. Active: {len(self._connections.get(user_id, set()))}")

    async def connect(self, user_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        self.register(user_id, websocket)

    async def disconnect(self, user_id: str, websocket: WebSocket) -> None:
        if user_id in self._connections:
            self._connections[user_id].discard(websocket)
            if not self._connections[user_id]:
                del self._connections[user_id]
        logger.info(f"WebSocket disconnected for user {user_id}.")

    async def send_to_user(self, user_id: str, event: dict) -> None:
        """Send an event to all WebSocket connections for a specific user."""
        sockets = list(self._connections.get(user_id, set()))

        message = json.dumps(event, default=str)
        stale = []
        for ws in sockets:
            try:
                await ws.send_text(message)
            except Exception:
                stale.append(ws)

        # Clean up stale connections
        if stale:
            for ws in stale:
                if user_id in self._connections:
                    self._connections[user_id].discard(ws)
                if user_id in self._connections and not self._connections[user_id]:
                    del self._connections[user_id]

    def broadcast_sync(self, user_id: str, event: dict) -> None:
        """Schedule a send_to_user from synchronous code (e.g., Firestore services).
        Safe to call from any thread — thread-safely dispatches to the captured event loop.
        """
        loop = getattr(self, "_loop", None)
        if loop and loop.is_running():
            future = asyncio.run_coroutine_threadsafe(self.send_to_user(user_id, event), loop)
            # Add a callback to log any exception from the coroutine
            def done_callback(fut):
                try:
                    fut.result()
                except Exception as e:
                    logger.error(f"Error in broadcast_sync coroutine: {e}", exc_info=True)
            future.add_done_callback(done_callback)
        else:
            try:
                loop = asyncio.get_running_loop()
                if loop.is_running():
                    asyncio.ensure_future(self.send_to_user(user_id, event))
                else:
                    loop.run_until_complete(self.send_to_user(user_id, event))
            except RuntimeError:
                pass

    def get_connected_users(self) -> list:
        """Return list of currently connected user IDs."""
        return list(self._connections.keys())

    def is_connected(self, user_id: str) -> bool:
        return user_id in self._connections and len(self._connections[user_id]) > 0
