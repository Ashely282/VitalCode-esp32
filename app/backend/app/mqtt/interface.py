from abc import ABC, abstractmethod


class MQTTInterface(ABC):

    @abstractmethod
    def connect(self) -> None:
        pass

    @abstractmethod
    def disconnect(self) -> None:
        pass

    @abstractmethod
    def publish(self, topic: str, payload: dict) -> None:
        pass

    @abstractmethod
    def subscribe(self, topic: str) -> None:
        pass