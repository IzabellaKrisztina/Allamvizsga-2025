from sqlalchemy import Table, Column, Integer, ForeignKey
from app.models.base import Base

favorites = Table(
    'favorites', Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), primary_key=True),
    Column('music_id', Integer, ForeignKey('musics.id'), primary_key=True)
)
