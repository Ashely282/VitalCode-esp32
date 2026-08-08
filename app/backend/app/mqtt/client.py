import json
import logging
from typing import Optional, Callable, Dict, Any, List
import paho.mqtt.client as mqtt
from app.mqtt.interface import MQTTInterface
from app.config import settings

logger = logging.getLogger(__name__)


class MQTTClient(MQTTInterface):
    _instance: Optional["MQTTClient"] = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._connected = False
            cls._instance._paho_client = None
            cls._instance._published_messages: List[Dict[str, Any]] = []
            cls._instance._subscriptions: Dict[str, Callable] = {}
        return cls._instance

    def _on_connect(self, client, userdata, flags, rc, properties=None):
        if rc == 0:
            self._connected = True
            logger.info("MQTT Client connected successfully to broker.")
            # Resubscribe existing topics
            for topic, callback in self._subscriptions.items():
                if self._paho_client:
                    self._paho_client.subscribe(topic)
        else:
            self._connected = False
            logger.warning(f"MQTT connection failed with code {rc}")

    def _on_disconnect(self, client, userdata, rc, properties=None):
        self._connected = False
        logger.info("MQTT Client disconnected.")

    def _on_message(self, client, userdata, msg):
        topic = msg.topic
        try:
            payload = json.loads(msg.payload.decode("utf-8"))
        except Exception:
            payload = msg.payload.decode("utf-8")

        for sub_topic, callback in self._subscriptions.items():
            if self._match_topic(sub_topic, topic) and callback:
                try:
                    callback(topic, payload)
                except Exception as e:
                    logger.error(f"Error in MQTT callback for topic {topic}: {e}")

    def _match_topic(self, sub_topic: str, actual_topic: str) -> bool:
        if sub_topic == actual_topic:
            return True
        sub_parts = sub_topic.split('/')
        act_parts = actual_topic.split('/')
        if len(sub_parts) != len(act_parts):
            return False
        for s, a in zip(sub_parts, act_parts):
            if s == '+' or s == a:
                continue
            if s.startswith('{') and s.endswith('}'):
                continue
            return False
        return True

    def connect(self) -> None:
        if self._connected:
            return
        try:
            client_id = getattr(settings, "MQTT_CLIENT_ID", "vitalcode_backend")
            broker = getattr(settings, "MQTT_BROKER", "localhost")
            port = getattr(settings, "MQTT_PORT", 1883)
            username = getattr(settings, "MQTT_USERNAME", None)
            password = getattr(settings, "MQTT_PASSWORD", None)
            tls = getattr(settings, "MQTT_TLS_ENABLED", False)

            client = mqtt.Client(client_id=client_id)
            if username:
                client.username_pw_set(username, password)
            if tls:
                client.tls_set()

            client.on_connect = self._on_connect
            client.on_disconnect = self._on_disconnect
            client.on_message = self._on_message

            client.connect_async(broker, port, keepalive=60)
            client.loop_start()
            self._paho_client = client
        except Exception as e:
            self._connected = False
            logger.warning(f"MQTT broker connection unavailable ({e}). Continuing safely.")

    def disconnect(self) -> None:
        if self._paho_client:
            try:
                self._paho_client.loop_stop()
                self._paho_client.disconnect()
            except Exception as e:
                logger.warning(f"Error disconnecting MQTT client: {e}")
        self._connected = False

    def publish(self, topic: str, payload: dict) -> None:
        message_record = {"topic": topic, "payload": payload}
        self._published_messages.append(message_record)

        if not self._connected or not self._paho_client:
            logger.debug(f"MQTT disconnected. Recorded publish to {topic}: {payload}")
            return

        try:
            str_payload = json.dumps(payload) if isinstance(payload, (dict, list)) else str(payload)
            self._paho_client.publish(topic, str_payload)
        except Exception as e:
            logger.warning(f"Failed to publish MQTT message to {topic}: {e}")

    def subscribe(self, topic: str, callback: Optional[Callable] = None) -> None:
        if callback:
            self._subscriptions[topic] = callback
        if self._connected and self._paho_client:
            try:
                self._paho_client.subscribe(topic)
            except Exception as e:
                logger.warning(f"Failed to subscribe to MQTT topic {topic}: {e}")

    @property
    def connected(self) -> bool:
        return self._connected

    def get_published_messages(self) -> List[Dict[str, Any]]:
        return self._published_messages

    def clear_published_messages(self) -> None:
        self._published_messages.clear()