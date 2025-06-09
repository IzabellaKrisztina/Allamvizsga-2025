
from sqlalchemy import Column, Integer, ForeignKey, Date
from sqlalchemy.orm import relationship
from app.models.base import Base

class DailyListening(Base):
    __tablename__ = "daily_listening"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    date = Column(Date, index=True)  # Save as date (YYYY-MM-DD)
    seconds_listened = Column(Integer, default=0)
    xp_earned = Column(Integer, default=0,  nullable=True)

    user = relationship("User", back_populates="daily_listening")
