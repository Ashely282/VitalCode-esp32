import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from app.config import settings


def initialize_firebase():
    if not firebase_admin._apps:
        cred_path = settings.FIREBASE_CREDENTIALS
        if not cred_path or not os.path.isfile(cred_path):
            raise ValueError(
                "FIREBASE_CREDENTIALS is missing or invalid: " + str(cred_path)
            )
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    return firestore.client()


def get_firestore():
    if not firebase_admin._apps:
        initialize_firebase()
    return firestore.client()