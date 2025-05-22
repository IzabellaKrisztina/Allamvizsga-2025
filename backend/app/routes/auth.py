import base64
from io import BytesIO
from fastapi import APIRouter, HTTPException, Depends, Body
from sqlalchemy.orm import Session
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta
from pydantic import BaseModel, EmailStr
from app.models import user, music, playlist
import app.database as database
from app.services import crud

router = APIRouter()

## .env fileba 
SECRET_KEY = "e456561899568d2927c6abe2bc62155216d0847e134e09336a01565de12f3ad5" ##generalva volt, lehet barmi
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 43800

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class LoginRequest(BaseModel):
    username: str
    password: str

class RegistrationRequest(BaseModel):
    username: str
    email: EmailStr
    password: str
    profile_picture: str

# sajatos token generalasa + validalas
def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=43800) # 1 honap
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def decode_base64_image(base64_string: str) -> bytes:
    img_data = base64.b64decode(base64_string)
    return BytesIO(img_data)

@router.post("/login")
def login(login_request: LoginRequest, db: Session = Depends(database.get_db)):
    user = crud.get_user_by_username(db, username=login_request.username)
    
    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")
    
    if not pwd_context.verify(login_request.password, user.password):
        raise HTTPException(status_code=400, detail="Invalid credentials")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/registration")
def register(request: RegistrationRequest, db: Session = Depends(database.get_db)):
    existing_user = db.query(user.User).filter((user.User.email == request.email) | (user.User.username == request.username)).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="User with this email or username already exists")
    
    hashed_password = pwd_context.hash(request.password)

    new_user = user.User(
        username=request.username,
        email=request.email,
        password=hashed_password,
        profile_picture=request.profile_picture
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "User registered successfully", "user_id": new_user.id}
