from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import Base
from app.models.favorites import favorites

class Music(Base):
    __tablename__ = "musics"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    artist = Column(String)
    playlist_id = Column(Integer, ForeignKey("playlists.id"))
    genre = Column(String)

    playlist = relationship("Playlist", back_populates="musics")
    users = relationship("User", secondary=favorites, back_populates="favorite_music")
