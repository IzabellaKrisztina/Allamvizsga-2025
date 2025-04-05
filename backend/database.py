from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from config import DATABASE_URL
from models.base import Base

DATABASE_URL = "postgresql://postgres:soundmind1235@db:5432/soundmind"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
