import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:soundmind1235@db:5432/soundmind")

OLLAMA_HOST = "ollama"
OLLAMA_PORT = 11434