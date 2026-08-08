import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = BASE_DIR / ".env"
load_dotenv(dotenv_path=ENV_PATH)


class Settings:
    @property
    def PROJECT_NAME(self):
        return os.getenv("PROJECT_NAME", "VITALCODE Backend")

    @property
    def API_VERSION(self):
        return os.getenv("API_VERSION", "1.0.0")

    @property
    def HOST(self):
        return os.getenv("HOST", "127.0.0.1")

    @property
    def PORT(self):
        return int(os.getenv("PORT", "8000"))

    @property
    def DEBUG(self):
        return os.getenv("DEBUG", "True").lower() in ("true", "1", "yes")

    @property
    def FIREBASE_CREDENTIALS(self):
        return os.getenv("FIREBASE_CREDENTIALS", None)

    @property
    def MQTT_BROKER(self):
        return os.getenv("MQTT_BROKER", "localhost")

    @property
    def MQTT_PORT(self):
        return int(os.getenv("MQTT_PORT", "1883"))

    @property
    def MQTT_USERNAME(self):
        return os.getenv("MQTT_USERNAME", None)

    @property
    def MQTT_PASSWORD(self):
        return os.getenv("MQTT_PASSWORD", None)

    @property
    def MQTT_CLIENT_ID(self):
        return os.getenv("MQTT_CLIENT_ID", "vitalcode_backend")

    @property
    def MQTT_TLS_ENABLED(self):
        return os.getenv("MQTT_TLS_ENABLED", "False").lower() in ("true", "1", "yes")


settings = Settings()