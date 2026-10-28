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

# Built list base on audio files.
IFL="$(find * -type f -name "x-aud-*" | sort -V)"
if [ -z "$IFL" ]; then
    echo "Audio files (x-aud-*) doesn't exists!"
    return 1
fi

# Main process.
echo "${IFL}" | while read -r xfiles
do
    ## Get layout SINGER - TITLE - ANALOG format from audio files.
    xpfiles="${xfiles#x-aud-}"; xffiles="${xpfiles%.*}"

    ## Build list audio/video files except instrument files.
    xafiles="$(find * -type f -name "x-aud-*$xffiles*" \! -iname "*_(Instrumental)*")"
    xvfiles="$(find * -type f -name "x-vid-*$xffiles*")"

    ## Random logo files.
    ranlogo="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    if [ -n "$xafiles" ] && [ -n "$xvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 -i "$xvfiles" | grep -Eo '[0-9]+')"

        if [ "$wvfiles" -ge 1280 ]; then
            ffmpeg $FFOPT -i "$xafiles" -i "$xvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720,format=yuv420p[video]; \
                             [2:v]scale=70:70,format=yuv420p[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-40:y=40:format=yuv422[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -q:v 6 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$xffiles".mpg
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            ffmpeg $FFOPT -i "$xafiles" -i "$xvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720,format=yuv420p[video]; \
                             [2:v]scale=60:60,format=yuv420p[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-40:y=40:format=yuv422[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -q:v 6 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$xffiles".mpg
        elif [ "$wvfiles" -lt 854 ]; then
            ffmpeg $FFOPT -i "$xafiles" -i "$xvfiles" -i "$ranlogo" \
            -filter_complex "[0:a]pan=stereo|c0=c0|c1=c1[audio]; \
                             [1:v]scale=-2:720,format=yuv420p[video]; \
                             [2:v]scale=50:50,format=yuv420p[logo]; \
                             [video][logo]overlay=x=main_w-overlay_w-40:y=40:format=yuv422[outv]" \
            -c:a mp2 -q:a 3 -b:a 320K -ar 48000 -map "[audio]" \
            -map "[outv]" -c:v mpeg2video -pix_fmt yuv420p -q:v 6 -r 25 -b:v 4000k -maxrate 6000k -bufsize 8000k $FINSDIR/"$xffiles".mpg
        fi
    else
        echo "$xxfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
