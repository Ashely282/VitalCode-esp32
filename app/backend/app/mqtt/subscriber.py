import logging
from typing import Callable, Optional
from app.mqtt.client import MQTTClient

logger = logging.getLogger(__name__)


class MQTTSubscriber:
    def __init__(self):
        self.client = MQTTClient()

    def subscribe(self, topic: str, callback: Optional[Callable] = None) -> None:
        try:
            self.client.subscribe(topic, callback)
            logger.info(f"Subscribed to MQTT topic: {topic}")
        except Exception as e:
            logger.warning(f"MQTT subscribe failed for topic {topic}: {e}")