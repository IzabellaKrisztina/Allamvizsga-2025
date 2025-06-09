from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import Base


class Favorite(Base):
    __tablename__ = 'favorites'

    user_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    music_id = Column(Integer, ForeignKey('musics.id'), primary_key=True)

    user = relationship("User", back_populates="favorite_musics_assoc")
    music = relationship("Music", back_populates="favorited_by_assoc")
