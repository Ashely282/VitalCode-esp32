from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.user import UserCreate, UserUpdate


class UserService:
    def create_user(self, data: UserCreate, user_id: str = None) -> str:
        if user_id:
            doc_ref = db.collection(Collections.USERS.value).document(user_id)
        else:
            doc_ref = db.collection(Collections.USERS.value).document()
        doc_ref.set(data.model_dump(exclude_unset=True))
        return doc_ref.id

    def get_user(self, user_id: str):
        doc = db.collection(Collections.USERS.value).document(user_id).get()

        if not doc.exists:
            return None

        return {
            "id": doc.id,
            **doc.to_dict(),
        }

    def update_user(self, user_id: str, data: UserUpdate) -> None:
        db.collection(Collections.USERS.value).document(user_id).update(data.model_dump(exclude_unset=True))

    def delete_user(self, user_id: str) -> None:
        db.collection(Collections.USERS.value).document(user_id).delete()

    def list_users(self):
        docs = db.collection(Collections.USERS.value).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]