
from fastapi import FastAPI
from app.routes import auth, analyze_mood, user_routes

app = FastAPI()

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(analyze_mood.router, prefix="/mood", tags=["mood"])
app.include_router(user_routes.router, prefix="/users", tags=["users"])
