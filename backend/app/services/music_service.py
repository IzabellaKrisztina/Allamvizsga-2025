import requests
import json
import re
from dotenv import load_dotenv
import os

load_dotenv()

OLLAMA_HOST = os.getenv("OLLAMA_HOST")
OLLAMA_PORT = os.getenv("OLLAMA_PORT")

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
