import logging
from app.mqtt.client import MQTTClient

logger = logging.getLogger(__name__)


class MQTTPublisher:
    def __init__(self):
        self.client = MQTTClient()

    def publish(self, topic: str, payload: dict) -> bool:
        try:
            self.client.publish(topic, payload)
            return True
        except Exception as e:
            logger.warning(f"MQTT publish failed for topic {topic}: {e}")
            return False