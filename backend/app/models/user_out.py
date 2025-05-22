from pydantic import BaseModel

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    xp: int
    profile_picture: str | None = None

    class Config:
        from_attributes = True
