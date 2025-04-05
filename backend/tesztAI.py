import requests

API_URL = "https://api-inference.huggingface.co/models/ehcalabres/wav2vec2-lg-xlsr-en-speech-emotion-recognition"
# API_URL = "https://api-inference.huggingface.co/models/openai/whisper-large"   # hangbol szoveget ad vissza

def query(filename):
    with open(filename, "rb") as f:
        response = requests.post(API_URL, headers=headers, data=f)
    return response.json()

output = query("wow.wav")
# output = query("good_little_girl.wav")

print(output)
 


 
