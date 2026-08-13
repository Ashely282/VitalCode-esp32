from app.firebase.database import db
from app.models.firestore_schema import Collections
from app.schemas.caregiver import CaregiverCreate, CaregiverUpdate


class CaregiverService:
    def create_caregiver(self, data: CaregiverCreate) -> str:
        doc_ref = db.collection(Collections.CAREGIVERS.value).document()
        doc_ref.set(data.model_dump(exclude_unset=True))
        return doc_ref.id

    def get_caregiver(self, caregiver_id: str):
        doc = db.collection(Collections.CAREGIVERS.value).document(caregiver_id).get()

        if not doc.exists:
            return None

        return {
            "id": doc.id,
            **doc.to_dict(),
        }

    def update_caregiver(self, caregiver_id: str, data: CaregiverUpdate) -> None:
        db.collection(Collections.CAREGIVERS.value).document(caregiver_id).update(data.model_dump(exclude_unset=True))

    def delete_caregiver(self, caregiver_id: str) -> None:
        db.collection(Collections.CAREGIVERS.value).document(caregiver_id).delete()

    def list_caregivers(self):
        docs = db.collection(Collections.CAREGIVERS.value).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]

    def check_primary_exists(self, patient_id: str, exclude_id: str = None) -> bool:
        docs = db.collection(Collections.CAREGIVERS.value).where("assigned_patient_id", "==", patient_id).stream()
        for doc in docs:
            if exclude_id and doc.id == exclude_id:
                continue
            data = doc.to_dict() or {}
            if data.get("is_primary") is True:
                return True
        return False

    def list_caregivers_by_patient(self, patient_id: str):
        docs = db.collection(Collections.CAREGIVERS.value).where("assigned_patient_id", "==", patient_id).stream()
        return [
            {
                "id": doc.id,
                **doc.to_dict(),
            }
            for doc in docs
        ]