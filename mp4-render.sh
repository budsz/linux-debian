#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FINSDIR="$BASEDIR/Finished"
LOGODIR="$BASEDIR/logos"
LOGONAME="otp"
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

# Built list base on instrument files.
IFL="$(find * -type f -name "*_\(Instrumental\).*")"
if [ -z "$IFL" ]; then
    echo "Instrument files doesn't exists!"
    return 1
fi

# Main process.
echo "${IFL}" | while read -r difiles
do
    ## Get layout SINGER - TITLE format from instrument files.
    dsfiles="$(echo $difiles | awk -F ' - ' '{print $1, "-", $2}' | sed 's/\(.*\)d-aud-//;s/\(.*\)f-aud-//')"
    dtfiles="$(echo $difiles | cut -d '-' -f 3,4,5 | sed 's/_(Instrumental).wav//')"
    dofiles="$(echo $dtfiles - MR)"

    ## Build list audio/video files except instrument files.
    dafiles="$(find * -type f -name "d-aud*$dsfiles*" \! -iname "*_(Instrumental)*")"
    dvfiles="$(find * -type f -name "d-vid*$dsfiles*")"

    ## Random logo files.
    ranlogo="$(find $LOGODIR -maxdepth 1 -type f -name "$LOGONAME-*.svg" | shuf -n 1)"

    ## Rendering audio + video + logo.
    #if [ -n "$dafiles" ] && [ -n "$dvfiles" ] && [ ! -f $FINSDIR/"$dofiles".mpg ]; then
    if [ -n "$dafiles" ] && [ -n "$dvfiles" ]; then
        ## Checking width video files.
        wvfiles="$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 -i "$dvfiles")"

        if [ "$wvfiles" -ge 1280 ]; then
            ffmpeg $FFOPT -i "$dafiles" -i "$difiles" -i "$dvfiles" -i "$ranlogo" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=50:50[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map "[audio]" \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$dofiles".mp4
        elif [ "$wvfiles" -ge 854 ] && [ "$wvfiles" -lt 1280 ]; then
            ffmpeg $FFOPT -i "$dafiles" -i "$difiles" -i "$dvfiles" -i "$ranlogo" \
                -filter_complex "[0:a]aformat=channel_layouts=stereo[a0]; \
                                 [1:a]aformat=channel_layouts=stereo[a1]; \
                                 [a0][a1]amerge=inputs=2, \
                                 pan=stereo|c0=c0|c1=c2[audio], \
                                 [2:v]scale=-2:720[video]; \
                                 [3:v]scale=45:45[logo]; \
                                 [video][logo]overlay=x=main_w-overlay_w-35:y=25:format=auto[outv]" \
            -c:a aac -ar 48000 -b:a 192k -map "[audio]" \
            -map "[outv]" -c:v libx264 -crf 20 \
            -metadata:s handler_name="IT & Sound Dept -- Studio Family Karaoke" \
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$dofiles".mp4
        elif [ "$wvfiles" -lt 854 ]; then
            ffmpeg $FFOPT -i "$dafiles" -i "$difiles" -i "$dvfiles" -i "$ranlogo" \
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
            -metadata:g encoding_tool="Modified Encoding by eSFK-1.0.5" \
            -fflags +bitexact -flags:v +bitexact -flags:a +bitexact \
            $FINSDIR/"$dofiles".mp4
        fi
    else
        echo "$dsfiles: Audio/video/logo files: NULL -OR- target file already exists."
    fi
done

# CD current directory.
cd
