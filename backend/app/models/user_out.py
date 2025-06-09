from typing import Optional
from pydantic import BaseModel

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    total_xp: Optional[int] = None
    profile_picture: Optional[str]  = None

    class Config:
        from_attributes = True
