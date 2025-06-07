import requests
import json
import re
from dotenv import load_dotenv
import os
from transformers import pipeline

load_dotenv()

OLLAMA_HOST = os.getenv("OLLAMA_HOST")
OLLAMA_PORT = os.getenv("OLLAMA_PORT")

SPEECH_EMOTION_RECOGNITION_URL = os.getenv("SPEECH_EMOTION_RECOGNITION_URL")
BEARER_TOKEN_HUGGINGFACE = os.getenv("BEARER_TOKEN_HUGGINGFACE")

def query_llama2(prompt_dict):
    print("Sending request to Ollama...")
    url = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(url, json=prompt_dict, headers=headers)
        response.raise_for_status()
        matches = re.findall(r'"response":\s*"([^"]*)"', response.text)
        response_text = " ".join(matches).strip()
        print(response_text)
        return response_text
    except requests.exceptions.RequestException as e:
        raise Exception(f"Error querying Ollama: {e}")
    except ValueError as e:
        raise Exception(f"Error decoding JSON: {e}")

def make_prompt_to_llama(preferences):
    base_prompt = "Given the following answers, return a single word representing the music genre that best describes the person who answered these questions. Only respond with one word: "
    formatted_answers = []
    for idx, (question, answer) in enumerate(preferences.items(), start=1):
        formatted_answers.append(f"{idx}. {question} {answer}")
    full_prompt = base_prompt + " ".join(formatted_answers)
    prompt_dict = {
        "model": "llama3:latest",
        "prompt": full_prompt
    }
    return prompt_dict

def query_llama2_song(prompt_dict):
    url = f"http://{OLLAMA_HOST}:{OLLAMA_PORT}/api/generate"
    headers = {"Content-Type": "application/json"}
    try:
        response = requests.post(url, json=prompt_dict, headers=headers)
        response.raise_for_status()
        matches = re.findall(r'"response":\s*"([^"]*)"', response.text)
        response_text = " ".join(matches).strip()
        # print(response_text)
        return response_text
    except requests.exceptions.RequestException as e:
        raise Exception(f"Error querying Ollama: {e}")
    except ValueError as e:
        raise Exception(f"Error decoding JSON: {e}")

def get_music_genre(preferences):
    print("izatol van: ")
    print(preferences)
    prompt_dict = make_prompt_to_llama(preferences)
    response = query_llama2(prompt_dict)
    return response

def make_prompt_to_llama_for_songs(preferences):
    base_prompt = "Given the following mood, artist, and activity, return **exactly** 10 song recommendations in the format 'Song Title Artist Name'. Do **not** include any additional text, explanations, or numbering. Only return the song titles and their corresponding artists. For example: 'Song Title - Artist Name'. Do **not** add any extra words or sentences before or after the list.\n\n"
    full_prompt = base_prompt + preferences
    prompt_dict = {
        "model": "llama3:latest",
        "prompt": full_prompt
    }
    return prompt_dict

def make_prompt_to_llama_for_songs_with_mood_and_genre(mood, genre):
    base_prompt = "Given the following mood and genre, return **exactly** 10 song recommendations in the format 'Song Title Artist Name'. Do **not** include any additional text, explanations, or numbering. Only return the song titles and their corresponding artists. For example: 'Song Title - Artist Name'. Do **not** add any extra words or sentences before or after the list.\n\n"
    full_prompt = base_prompt + f"Mood: {mood}, Genre: {genre}"
    prompt_dict = {
        "model": "llama3:latest",
        "prompt": full_prompt
    }
    return prompt_dict

def predict_emotion_from_audio(file_path: str) -> str:
    try:
        api_url = os.getenv("SPEECH_EMOTION_RECOGNITION_URL")
        api_token = os.getenv("BEARER_TOKEN_HUGGINGFACE")

        headers = {
            "Authorization": f"Bearer {api_token}"
        }

        with open(file_path, "rb") as f:
            response = requests.post(api_url, headers=headers, data=f)

        try:
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            raise Exception(f"HuggingFace API error: {response.text}")

        result = response.json()
        print("🔍 Raw HuggingFace Response:", result)

        if isinstance(result, list) and result:
            top_prediction = max(result, key=lambda x: x.get('score', 0))
            emotion = top_prediction.get('label', '').lower()
            print("🎤 Predicted Emotion:", emotion)
            return emotion
        else:
            raise ValueError("Empty or invalid response from model.")
    except Exception as e:
        raise Exception(f"Error in emotion prediction: {e}")
