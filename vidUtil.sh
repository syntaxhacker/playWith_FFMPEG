#! /bin/bash
dlSubs(){
    youtube-dl --list-subs $URL
    youtube-dl --write-sub --sub-lang en --skip-download $URL
}
dlPlaylist(){
    if [ -z "$1" ] || [ "$1" == "-h" ] ; then
        printf "params \n # 1 - youtube playlist url \n"
        exit 0
    fi 

# download vids
    youtube-dl -f "bestvideo[height<="1080"]+bestaudio/best[height<="1080"]" -o "%(playlist_index)02d.%(ext)s" "$1"
    # trim
shopt -s nullglob
for file in *.{webm,mkv,mp4}; do
echo "FILE - $file"
FILEEXT=`echo "$file" | cut -d'.' -f2`
FILENAME=`echo "$file" | cut -d'.' -f1`
if [ "$FILEEXT" == "mkv" ] ; then
    ffpb -y -hwaccel cuvid -c:v h264_cuvid -i  "$file"  -ss "00:00:10.000" -to  "00:00:15.000" -c:v h264_nvenc -c copy  "trim.mkv"
    rm $file
    mv trim.mkv  $file
    
    ffpb -y -hwaccel cuvid -c:v h264_cuvid -i "$file" -strict -2 -c:v h264_nvenc -c copy  "conv.mp4"
  
    rm $file
    mv conv.mp4 "$FILENAME".mp4
    elif [ "$FILEEXT" == "webm" ] ; then
    ffmpeg -hide_banner -y -hwaccel cuvid  -strict -2 -i  "$file"  -ss "00:00:10.000" -to  "00:00:15.000" -c:v h264_nvenc -c copy  "trim.webm"
    rm $file
    mv trim.webm $file
    ffpb -hwaccel cuvid -y -i "$file"  -c:v h264_nvenc  "conv.mp4"
    rm $file
    mv conv.mp4 "$FILENAME".mp4
    elif [ "$FILEEXT" == "mp4" ] ; then
    ffpb -y -hwaccel cuvid -c:v h264_cuvid -i  "$file"  -ss "00:00:10.000" -to  "00:00:15.000" -c:v h264_nvenc -c copy  "trim.mp4"
    rm $file
    mv trim.mp4 $file
fi
done



    FILE=$PWD/files.txt
    if test -f "$FILE"; then
        echo "deleting file ."
        rm $FILE
    fi

for i in *mp4 ; do
    echo "file '$i' " >> files.txt
done
# concat
ffmpeg  -y -hwaccel cuvid -c:v h264_cuvid  -f concat -i files.txt -strict -2  -c:v h264_nvenc -c copy "out.mp4"
    # download highest quality video with indexes as file name
    # youtube-dl -o "%(playlist_index)02d.%(ext)s" "$1"
    # download from networkk
    # ffmpeg -y -f concat -safe 0  -protocol_whitelist "file,http,https,tcp,tls"  -i list.txt -c copy out.mp4 > /dev/null 2>&1
    # youtube-dl -f 303+140 -i PL4cUxeGkcC9iHDnQfTHEVVceOEBsOf07i
}
vidSs(){
    if [ -z "$1" ] || [ "$1" == "-h" ] ; then
        printf "params \n # 1 - video name \n"
        exit 0
    fi

    ffmpeg -ss 00:00:40 -i "$1" -vframes 1 -q:v 2 "$1".jpg > /dev/null 2>&1
    #     #take range based screenshots
       ffmpeg -i "$1" -vframes 1 -q:v 2 -vf "select=not(mod(n\,100)),scale=-1:480,tile=3x5" -an "out.jpg" > /dev/null 2>&1

}

resizeVid(){
     if [ -z "$1" ] || [ "$1" == "-h" ] ; then
        printf "
        # 1 - ip video
        # 2 - resolution
        # 3 - out video"
        exit 0
    fi
    # gpu
    if [ "$USEGPU" = "true" ] ; then
        # @param
        !ffpb  -y -vsync 0 -hwaccel cuvid -hwaccel_device 0 -c:v h264_cuvid -resize "$2" -i "$1"  -strict -2  -c:a copy -c:v h264_nvenc -b:v 5M "$3"
    else
        !ffpb -y -i "$1" -s "$2"  -c:a copy "$3"
    fi
}

getframes(){
    ffprobe -show_streams  $1| grep "^nb_frames" | cut -d '=' -f 2
}
makeLofi(){
     if [ -z "$1" ] || [ "$1" == "-h" ] ; then
        printf "
        # 1 - ip music file
        # 2 - ip  gif
        # 3 - out video"
        exit 0
    fi
    if [ "$USEGPU" = "true" ] ; then
    ffmpeg  -hwaccel cuvid -c:v h264_cuvid -i "$1" -ignore_loop 0 -i "$2" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -shortest -strict -2  -c:v h264_nvenc -threads 4 -c:a aac -b:a 192k -pix_fmt yuv420p -shortest lofi.mp4
    else
    ffmpeg -i "$1" -ignore_loop 0 -i "$2" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -shortest -strict -2 -c:v libx264 -threads 4 -c:a aac -b:a 192k -pix_fmt yuv420p -shortest lofi.mp4
    fi
}

trimVid(){
    # cpu
    ffmpeg -i "BigBuckBunny.mp4" -ss "00:00:00.000" -to "00:00:30.000" -c copy out.mp4
}

cleanup(){
    rm *.mkv
    rm *.zip
    rm *.txt
    rm *.webm
    rm *.mp4
    rm *.mp3
    rm *.gif
    rm *.ass
    rm *.vtt
    rm *.jpg
}
vidInfo(){
    ffprobe -v quiet -print_format json -show_format -show_streams naruto.mp4
}
streamToTwitch(){
ffmpeg  -hide_banner  -i input.mp4 -vcodec libx264 -b:v 5M -acodec aac -b:a 256k -f flv rtmp://live.twitch.tv/app/$KEY
}
burnSubs(){
    # @param
    # 1 - ip video
    # 2 - out video
    # 3 - subtitle
    if [ -z "$1" ] || [ "$1" == "-h" ] ; then
        printf "params \n # 1 - ip video \t # 2 - out video \t # 3 - subtitle name \n"
        exit 0
    fi
    if [ "$USEGPU" = "true" ] ; then
        ffpb -i "$3".vtt "$3".ass
        ffpb -i "$1" -c:v h264_nvenc -c:a copy -vf  "subtitles=sub.ass:force_style='FontName=arial,FontSize=24'" -b:v 5M "$2"
    fi
    # !ffpb -y -vsync 0 -hwaccel cuvid -hwaccel_device 0 -c:v h264_cuvid  -i name.mp4 ass="$3".ass "gpusubbed.mp4"
}
combineVidList() {
    ffmpeg -y -f concat -i files.txt -c copy "out".mp4
}


galleryDownload(){
    vcsi "$1" \
    -t \
    -w 850 \
    -g 2x2 \
    --background-color 090909 \
    --metadata-font-color ffffff \
    --end-delay-percent 20 \
    # --metadata-font "/usr/share/fonts/truetype/humor-sans/Humor-Sans.ttf"
}

if [ "$1" == "pkgs" ]; then
    pip install vcsi ffpb pytube3 2>&1
    sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl 2>&1
    sudo chmod a+rx /usr/local/bin/youtube-dl 2>&1
    exit 0
fi
# compute with cpu or gpu
USEGPU=false
nvidia-smi > /dev/null 2>&1
if [ $? -eq 0 ]
then
    echo "using GPU "
    # nvidia-smi --query-gpu=gpu_name,driver_version,memory.total --format=csv
    USEGPU=true
else
    echo "Using CPU "
fi

################################
# Main script
################################

# check for less number of arguments
if [ $# -lt 1 ]; then
    printf "No arguments provided! \nUse -h for Usage\n"
    exit 0
fi

if [ "$1" == "-h" ] ; then
    echo "
USAGE ./vidUtil.sh [ARGS]
-g :   Generate Gallery
-d :   Cleanup
-ss :   Take screenshot
-subs: Burn subs to vid
-c :   concat videos
    "
    exit 0
fi

case "$1" in
    "-p")
        dlPlaylist "$2"
    ;;
    "-subs")
        burnSubs "$2"
    ;;
    "-c")
        combineVidList
    ;;
    "-ss")
        vidSs "$2"
    ;;
    "-d")
        cleanup
    ;;
    "-g")
        galleryDownload "$2"
    ;;
    *)
        echo -n "unknown command"
    printf "No arguments provided! \nUse -h for Usage\n"
    exit 0
    ;;
esac
