from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.notification import NotificationCreate, NotificationUpdate


class NotificationService:
    def create_notification(self, data: NotificationCreate) -> str:
        doc_ref = db.collection(Collections.NOTIFICATIONS.value).document()
        doc_ref.set(data.model_dump(exclude_unset=True))
        return doc_ref.id

    def get_notification(self, notification_id: str):
        doc = db.collection(Collections.NOTIFICATIONS.value).document(notification_id).get()

        if not doc.exists:
            return None

        return {
            "id": doc.id,
            **doc.to_dict(),
        }

    def update_notification(self, notification_id: str, data: NotificationUpdate) -> None:
        db.collection(Collections.NOTIFICATIONS.value).document(notification_id).update(data.model_dump(exclude_unset=True))

    def delete_notification(self, notification_id: str) -> None:
        db.collection(Collections.NOTIFICATIONS.value).document(notification_id).delete()

    def list_notifications(self):
        docs = db.collection(Collections.NOTIFICATIONS.value).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def list_notifications_by_recipient(self, recipient_id: str):
        docs = db.collection(Collections.NOTIFICATIONS.value).where("recipient_id", "==", recipient_id).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]