#! /opt/python/latest/bin/python3

# pip install pytube3
# use python 3.8
from pytube import YouTube
from pytube import Playlist
import re
import os
import sys


def noOutput():
    f = open(os.devnull, 'w')
    sys.stdout = f
    f = open('/dev/null', 'w')
    sys.stdout = f


if len(sys.argv) < 2:
    print("enter -p URL for playlist \n -v URL for video")
else:
    url = sys.argv[2]
    if sys.argv[1] == "-p":
        print("downloading playlist...\n")
        playlist = Playlist(url)
        print(Playlist(url).streams)
        playlist._video_regex = re.compile(r"\"url\":\"(/watch\?v=[\w-]*)")
        print(playlist._video_regex)
        # playlist.download_all()
    elif sys.argv[2] == "-v":
        ytd = YouTube(url).streams.first().download()
        print(ytd)
    else:
        print("enter valid command")
# https://www.youtube.com/playlist?list=PLxGGROpi9teLLvAUU0DbLy-Jhws8PHGWS
# from pytube import Playlist
# playlist = Playlist('https://www.youtube.com/playlist?list=PL6gx4Cwl9DGCkg2uj3PxUWhMDuTw3VKjM')
# print('Number of videos in playlist: %s' % len(playlist.video_urls))
# for video_url in playlist.video_urls:
#     print(video_url)
# playlist.download_all()
