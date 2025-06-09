from sqlalchemy.orm import Session
from app.models import user
from app.models.user_preference import UserPreference
from app.models.user import User

def get_user_by_username(db: Session, username: str):
    return db.query(user.User).filter(user.User.username == username).first()

def get_user_by_email(db: Session, email: str):
    return db.query(user.User).filter(user.User.email == email).first()


# def create_or_update_user_preferences(db: Session, user_id: int, preferences: dict):
#     existing = db.query(UserPreference).filter_by(user_id=user_id).first()
#     if existing:
#         existing.preferences = preferences
#     else:
#         existing = UserPreference(user_id=user_id, preferences=preferences)
#         db.add(existing)
#     db.commit()
#     db.refresh(existing)
#     return existing

# def get_user_preferences(db: Session, user_id: int):
#     return db.query(UserPreference).filter_by(user_id=user_id).first()