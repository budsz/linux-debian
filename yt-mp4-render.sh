#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished"
LOGODIR="$BASEDIR/logos"
LOGONAME="yt"
FFOPT="-hide_banner -nostdin -y"

# Move to basedir.
if [ ! -d "$BASEDIR" ]; then
    mkdir $BASEDIR
    cd $BASEDIR
else
    cd $BASEDIR
fi

# Check logo directory.
if [ ! -d "$LOGODIR" ]; then
    mkdir $LOGODIR
fi

# Built list base on audio files.
FL="$(find * -type f -name "y-aud-*")"
if [ -z "$FL" ]; then
    echo "YT Audio files doesn't exists!"
    return 1
fi

# Main process.
echo "${FL}" | while read -r yafiles
do
    ## Fixed '[]' to '\[\]' chars.
    yafiles="$(echo $yafiles | sed 's/\[/\\[/g;s/\]/\\]/g')"

    ## Get layout SINGER - TITLE format from audio files.
    yfsfiles="$(echo $yafiles | awk -F ' - ' '{print $1, "-", $2}' | sed 's/\(.*\)y-aud-//')"
    yftfiles="$(echo $yafiles | cut -d '-' -f 3,4,5 | sed 's/\.[^.]*$//')"

    ## Fixed '\[\]' to '[]' chars.
    yfofiles="$(echo $yftfiles - ST | sed 's/\\\[/[/g;s/\\\]/]/g')"

    ## Build list audio/video files files.
    yfafiles="$(find . -type f -name "y-aud*$yfsfiles*" \! -iname "*_(Instrumental)*")"
    yfvfiles="$(find . -type f -name "y-vid*$yfsfiles*")"

    ## Random logo files.
    nologos="$LOGODIR/null.svg"
    #ranlogos="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    #if [ -n "$yfafiles" ] && [ -n "$yfvfiles" ] && [ ! -f $FINSDIR/"$yfofiles".mpg ]; then
    if [ -n "$yfafiles" ] && [ -n "$yfvfiles" ]; then
        ## Checking width video files.
        hvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 -i "$yfvfiles")"

        if [ "$hvfiles" -ge 720 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfvfiles" -i "$nologos" \
                -filter_complex "[1:v]scale=-2:$hvfiles[video]; \
                                 [2:v]scale=50:-2[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-30:y=25:format=auto,format=yuv420p[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map 0:a \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-YT" \
            $FINSDIR/"$yfofiles".mp4
        elif [ "$hvfiles" -ge 480 ] && [ "$hvfiles" -le 720 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfvfiles" -i "$nologos" \
                -filter_complex "[1:v]scale=-2:$hvfiles[video]; \
                                 [2:v]scale=40:-2[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-25:y=20:format=auto,format=yuv420p[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map 0:a \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-YT" \
            $FINSDIR/"$yfofiles".mp4
        elif [ "$hvfiles" -ge 360 ] && [ "$hvfiles" -le 480 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfvfiles" -i "$nologos" \
                -filter_complex "[1:v]scale=-2:$hvfiles[video]; \
                                 [2:v]scale=30:-2[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-20:y=15:format=auto,format=yuv420p[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map 0:a \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-YT" \
            $FINSDIR/"$yfofiles".mp4
        elif [ "$hvfiles" -ge 240 ] && [ "$hvfiles" -le 360 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfvfiles" -i "$nologos" \
                -filter_complex "[1:v]scale=-2:$hvfiles[video]; \
                                 [2:v]scale=50:-2[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-15:y=10:format=auto,format=yuv420p[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map 0:a \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-YT" \
            $FINSDIR/"$yfofiles".mp4
        else
            echo "Unable to determine screen and video resolution!"
        fi
    else
        echo "$yfsfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
