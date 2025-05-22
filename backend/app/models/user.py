from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.models.base import Base
from app.models.music import Music
from app.models.favorites import favorites

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String, index=True)
    xp = Column(Integer, nullable=True, default=0)
    profile_picture = Column(String, nullable=True)

    playlists = relationship("Playlist", back_populates="owner")
    favorite_music = relationship("Music", secondary=favorites, back_populates="users")
