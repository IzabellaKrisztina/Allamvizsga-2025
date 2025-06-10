from fastapi import FastAPI, File, UploadFile
from transformers import AutoModelForAudioClassification, AutoFeatureExtractor
import torch
import librosa
import numpy as np
from io import BytesIO

app = FastAPI()

# Load model and feature extractor
model_id = "firdhokk/speech-emotion-recognition-with-openai-whisper-large-v3"
model = AutoModelForAudioClassification.from_pretrained(model_id)
feature_extractor = AutoFeatureExtractor.from_pretrained(model_id)
id2label = model.config.id2label

def preprocess_audio_file(file_bytes, feature_extractor, max_duration=30.0):
    audio_array, sampling_rate = librosa.load(BytesIO(file_bytes), sr=feature_extractor.sampling_rate)

    max_length = int(feature_extractor.sampling_rate * max_duration)
    if len(audio_array) > max_length:
        audio_array = audio_array[:max_length]
    else:
        audio_array = np.pad(audio_array, (0, max_length - len(audio_array)))

    inputs = feature_extractor(
        audio_array,
        sampling_rate=feature_extractor.sampling_rate,
        max_length=max_length,
        truncation=True,
        return_tensors="pt"
    )
    return inputs

def predict_emotion_from_inputs(inputs, model, id2label):
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model.to(device)
    inputs = {k: v.to(device) for k, v in inputs.items()}

    with torch.no_grad():
        outputs = model(**inputs)

    logits = outputs.logits
    predicted_id = torch.argmax(logits, dim=-1).item()
    predicted_label = id2label[predicted_id]
    
    return predicted_label

@app.post("/infer")
async def infer(file: UploadFile = File(...)):
    file_bytes = await file.read()
    inputs = preprocess_audio_file(file_bytes, feature_extractor)
    emotion = predict_emotion_from_inputs(inputs, model, id2label)
    return {"emotion": emotion}