#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished/FIN"
LOGODIR="$BASEDIR/logos"
LOGONAME="fin"
FFOPT="-hide_banner -nostdin -y"

# Move to basedir.
if [ ! -d "$BASEDIR" ]; then
    mkdir $BASEDIR
    cd $BASEDIR
else
    cd $BASEDIR
fi

# Check FIN directory.
if [ ! -d "$FINSDIR" ]; then
    mkdir $FINSDIR
fi

# Check logo directory.
if [ ! -d "$LOGODIR" ]; then
    mkdir $LOGODIR
fi

# Built list base on audi files.
IFL="$(find * -type f -name "f-aud-*" | sort -V)"
if [ -z "$IFL" ]; then
    echo "Audio files (f-aud-*) doesn't exists!"
    return 1
fi

# Main process.
echo "${IFL}" | while read -r fifiles
do
    ## Get layout SINGER - TITLE format from instrument files.
    #fafiles="$(echo $fifiles | awk -F ' - ' '{print $1, "-", $2}' | sed 's/\(.*\)f-aud-//')"
    fpfiles="${fifiles#f-aud-}"; fxfiles="${fpfiles% - *}"; fofiles="$(echo $fxfiles - ML)"

    ## Build list audio/video files except instrument files.
    fafiles="$(find * -type f -name "f-aud-*$fxfiles*" \! -iname "*_(Instrumental)*")"
    fvfiles="$(find * -type f -name "f-vid-*$fxfiles*")"

    ## Random logo files.
    ranlogo="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    if [ -n "$fafiles" ] && [ -n "$fvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 -i "$fvfiles")"

        if [ "$wvfiles" -ge 1280 ]; then
            ffmpeg $FFOPT -i "$fafiles" -i "$fvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720[video]; \
                             [2:v]scale=50:50[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$fofiles".mpg
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            ffmpeg $FFOPT -i "$fafiles" -i "$fvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720[video]; \
                             [2:v]scale=50:50[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$fofiles".mpg
        elif [ "$wvfiles" -lt 854 ]; then
            ffmpeg $FFOPT -i "$fafiles" -i "$fvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720[video]; \
                             [2:v]scale=50:50[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -q:v 12 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$fofiles".mpg
        fi
    else
        echo "Audio/video/logo files missing."
    fi
done

# CD current directory.
cd
