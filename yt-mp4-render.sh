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
    ranlogos="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    #if [ -n "$yfafiles" ] && [ -n "$yfvfiles" ] && [ ! -f $FINSDIR/"$yfofiles".mpg ]; then
    if [ -n "$yfafiles" ] && [ -n "$yfvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 -i "$yfvfiles")"

        if [ "$wvfiles" -ge 1280 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfafiles" -i "$yfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=40:40[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map "[audio]" \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-uar8fps0" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$yfofiles".mp4
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfafiles" -i "$yfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=35:35[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map "[audio]" \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-uar8fps0" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$yfofiles".mp4
        elif [ "$wvfiles" -lt 854 ]; then
            ffmpeg $FFOPT -i "$yfafiles" -i "$yfafiles" -i "$yfvfiles" -i "$ranlogos" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=30:30[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map "[audio]" \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5-uar8fps0" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$yfofiles".mp4
        fi
    else
        echo "$yfsfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
