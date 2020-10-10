
#! /opt/python/latest/bin/python3

from pytube import Playlist
playlist = Playlist('https://www.youtube.com/playlist?list=PLdxQ7SoCLQAMGgQAIAcyRevM8VvygTpCu').streams
print(playlist)

print('Number of videos in playlist: %s' % len(playlist.video_urls))
for video_url in playlist.video_urls:
    print(video_url)
# playlist.download_all()