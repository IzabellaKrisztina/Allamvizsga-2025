import os
from typing import Dict, Optional
from fastapi import APIRouter, HTTPException, File, UploadFile
from pydantic import BaseModel
from app.services.music_service import get_music_genre, make_prompt_to_llama, make_prompt_to_llama_for_songs, make_prompt_to_llama_for_songs_with_mood_and_genre, predict_emotion_from_audio, query_llama2, query_llama2_song
from dotenv import load_dotenv
import spotipy
import json
from spotipy.oauth2 import SpotifyClientCredentials
import re
import shutil
import wave

router = APIRouter()

load_dotenv()

class QuestionAnswer(BaseModel):
    question_answer: Dict[str, str]

class SongRequest(BaseModel):
    mood: str
    artist: str
    activity: str

user_preferences: Optional[QuestionAnswer] = None

def create_songs_prompt(mood: str, artist: str, activity: str):
    return f"Mood: {mood}, Artist: {artist}, Activity: {activity}"

def get_playlist_from_spotify(genre: str):
    client_id = os.getenv("SPOTIFY_CLIENT_ID")
    client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")

    client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
    sp = spotipy.Spotify(auth_manager=client_credentials_manager)

    result = sp.search(q=f"genre:{genre}", type="playlist", limit=5)

    playlists = []

    if result and 'playlists' in result and 'items' in result['playlists']:
        for playlist in result['playlists']['items']:
            if playlist:
                name = playlist.get('name', 'Nincs név')
                description = playlist.get('description', 'Nincs leírás')
                url = playlist['external_urls']['spotify'] if 'external_urls' in playlist else None
                image_url = playlist['images'][0]['url'] if 'images' in playlist and playlist['images'] else None

                playlists.append({
                    "name": name,
                    "description": description,
                    "url": url,
                    "image_url": image_url
                })

    formatted_json = json.dumps(playlists, indent=4, ensure_ascii=False)
    print(formatted_json)

    # return formatted_json
    return {"playlists": playlists}

@router.post("/analyze_mood")
async def analyze_mood(preferences: QuestionAnswer, user_id: str):
    try:
        genre = get_music_genre(preferences.question_answer)
        print(genre)

        global user_preferences
        user_preferences = preferences

        playlist = get_playlist_from_spotify(genre)

        # return {"recommended_genre": genre}
        return playlist

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")

def clean_and_split_response(response: str):
    lines = response.split("\\n")
    cleaned_lines = []
    for line in lines:
        line = re.sub(r"(?<=\S) (?=\S)", "", line)
        line = re.sub(r"\s{2,}", " ", line)
        cleaned_lines.append(line.strip())
    song_list = []
    for line in cleaned_lines:
        parts = line.rsplit(" ", 1)
        if len(parts) == 2:
            title = parts[0].strip()
            artist = parts[1].strip()
            title = re.sub(r'([a-z])([A-Z])', r'\1 \2', title)
            title = re.sub(r'([A-Za-z])\s*([A-Za-z])', r'\1 \2', title)
            song_list.append([title, artist])
    #return cleaned_lines
    return song_list


def get_song_from_spotify(query: str):
    client_id = os.getenv("SPOTIFY_CLIENT_ID")
    client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")
    
    client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
    sp = spotipy.Spotify(auth_manager=client_credentials_manager)
    result = sp.search(q=query, type="track", limit=1)
    if result['tracks']['items']:
        track = result['tracks']['items'][0]
        album_images = track['album']['images']
        album_cover_url = album_images[0]['url'] if album_images else "Nincs elérhető borítókép"
        track_uri = result["tracks"]["items"][0]["uri"] if "tracks" in result and "items" in result["tracks"] and result["tracks"]["items"] else None
        return {
            "track_name": track['name'],
            "artist_name": track['artists'][0]['name'],
            "album_name": track['album']['name'],
            "release_date": track['album']['release_date'],
            "spotify_url": track['external_urls']['spotify'],
            "album_cover_url": album_cover_url,
            "track_uri": track_uri
        }
    return None

@router.post("/suggest_songs")
async def suggest_songs(request: SongRequest):
    try:
        user_input = create_songs_prompt(request.mood, request.artist, request.activity)
        prompt_dict = make_prompt_to_llama_for_songs(user_input)
        response = query_llama2_song(prompt_dict)
        cleaned_response = clean_and_split_response(response)
        print(cleaned_response)

        songs = []

        for song in cleaned_response:
            # spotify_song = get_song_from_spotify(song)
            # songs.append(spotify_song)
            if isinstance(song, list) and len(song) == 2:
                query = f"{song[0]} {song[1]}"  # title + artist
                spotify_song = get_song_from_spotify(query)
                if spotify_song:
                    songs.append(spotify_song)
                else:
                    print(f"❌ Song not found on Spotify for query: {query}")
            else:
                print(f"⚠️ Skipped malformed song entry: {song}")

        songs = [song for song in songs if song is not None]
        return {"songs": songs}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")


def is_valid_audio(file_path: str) -> bool:
    try:
        with wave.open(file_path, 'rb') as wf:
            frames = wf.getnframes()
            rate = wf.getframerate()
            duration = frames / float(rate)
            return duration > 0.5  # Require >0.5 seconds audio
    except wave.Error:
        return False

@router.post("/analyze_audio_mood")
async def analyze_audio_mood(file: UploadFile = File(...)):
    try:     
        global user_preferences
        if user_preferences is None:
            raise HTTPException(status_code=400, detail="User preferences not set.")
       
        temp_file_path = f"temp_{file.filename}"

        if not is_valid_audio(temp_file_path):
            os.remove(temp_file_path)
            raise HTTPException(status_code=400, detail="Audio file is empty or too short.")


        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        mood = predict_emotion_from_audio(temp_file_path)
        os.remove(temp_file_path)

        genre = get_music_genre(user_preferences.question_answer)
        print(genre)

        prompt_dict = make_prompt_to_llama_for_songs_with_mood_and_genre(mood, genre)
        response = query_llama2_song(prompt_dict)
        cleaned_response = clean_and_split_response(response)
    
        songs = []

        for song in cleaned_response:
            # spotify_song = get_song_from_spotify(song)
            # songs.append(spotify_song)
            if isinstance(song, list) and len(song) == 2:
                query = f"{song[0]} {song[1]}"  # title + artist
                spotify_song = get_song_from_spotify(query)
                if spotify_song:
                    songs.append(spotify_song)
                else:
                    print(f"❌ Song not found on Spotify for query: {query}")
            else:
                print(f"⚠️ Skipped malformed song entry: {song}")

        songs = [song for song in songs if song is not None]
        return {"songs": songs}

    except Exception as e:
        print("❌ Exception during mood analysis:", str(e))
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

