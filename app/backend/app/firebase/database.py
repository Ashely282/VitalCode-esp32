from google.cloud.firestore import Client, CollectionReference
from app.firebase.firebase import get_firestore


class FirestoreDatabase:
    def __init__(self) -> None:
        self._client: Client = get_firestore()

    @property
    def client(self) -> Client:
        return self._client

    def collection(self, collection_name: str) -> CollectionReference:
        return self._client.collection(collection_name)


db = FirestoreDatabase()