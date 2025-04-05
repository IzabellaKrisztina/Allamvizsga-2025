# EGY ZENERE LEHET RAKERESNI
# import spotipy
# from spotipy.oauth2 import SpotifyClientCredentials

# client_id = "266d670acec84058971b6d3ef1e6993e"
# client_secret = "266d670acec84058971b6d3ef1e6993e"

# client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
# sp = spotipy.Spotify(auth_manager=client_credentials_manager)

# query = "Enter Sandman Metallica"
# result = sp.search(q=query, type="track", limit=1)



# print(result)

# if result['tracks']['items']:
#     track = result['tracks']['items'][0]
    
#     track_name = track['name']
#     artist_name = track['artists'][0]['name']
#     album_name = track['album']['name']
#     release_date = track['album']['release_date']
#     spotify_url = track['external_urls']['spotify']
#     preview_url = track.get('preview_url', 'Nincs elérhető előnézet')
    
#     print(f"Dal: {track_name}")
#     print(f"Előadó: {artist_name}")
#     print(f"Album: {album_name}")
#     print(f"Megjelenési dátum: {release_date}")
#     print(f"Spotify Link: {spotify_url}")
#     print(f"Előnézet: {preview_url}")

# else:
#     print("Nem található a dal a Spotify-on.")


# PLAYLISTET AD VISSZA MUFAJ ALAPJAN
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

client_id = "266d670acec84058971b6d3ef1e6993e"
client_secret = "ef7eca4439d14b8d82db5a5b00a22046"

client_credentials_manager = SpotifyClientCredentials(client_id=client_id, client_secret=client_secret)
sp = spotipy.Spotify(auth_manager=client_credentials_manager)

genre = input("Add meg a műfajt (pl. rock, pop, jazz, hip-hop): ")

result = sp.search(q=f"genre:{genre}", type="playlist", limit=5)

if result['playlists']['items']:
    print(f"\nTalált Playlistek a '{genre}' műfajban:\n")
    for i, playlist in enumerate(result['playlists']['items'], 1):
        name = playlist['name']
        description = playlist['description'] if playlist['description'] else "Nincs leírás"
        url = playlist['external_urls']['spotify']
        print(f"{i}. {name}\n   Leírás: {description}\n   Link: {url}\n")
else:
    print(f"Nem találtunk lejátszási listákat a '{genre}' műfajban.")


