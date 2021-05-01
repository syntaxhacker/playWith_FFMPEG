#! /bin/bash
for i in *mkv ; do
    ffpb -i "$i" -map 0:v:0 -map 0:a:3 -map 0:s:0 -c copy "tel_${i}"
done