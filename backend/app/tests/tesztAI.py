import requests
from dotenv import load_dotenv
import os

load_dotenv()

SPEECH_EMOTION_RECOGNITION_URL = os.getenv("SPEECH_EMOTION_RECOGNITION_URL")
SPEECH_TO_TEXT_URL = os.getenv("SPEECH_TO_TEXT_URL")
BEARER_TOKEN_HUGGINGFACE = os.getenv("BEARER_TOKEN_HUGGINGFACE")

headers = {"Authorization": "Bearer " + BEARER_TOKEN_HUGGINGFACE}

def query(filename):
    with open(filename, "rb") as f:
        response = requests.post(SPEECH_EMOTION_RECOGNITION_URL, headers=headers, data=f)
    return response.json()

output = query("wow.wav")
# output = query("good_little_girl.wav")

print(output)
api-inference.huggingface.co