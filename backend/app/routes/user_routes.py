from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.services.crud import get_user_by_username
from app.database import get_db
from app.models.user_out import UserOut

router = APIRouter()

@router.get("/{username}", response_model=UserOut)
def read_user(username: str, db: Session = Depends(get_db)):
    user = get_user_by_username(db, username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user
