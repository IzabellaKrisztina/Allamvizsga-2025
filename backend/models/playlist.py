from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from models.base import Base

class Playlist(Base):
    __tablename__ = "playlists"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    user_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="playlists")
    musics = relationship("Music", back_populates="playlist")
