#!/bin/dash

LIST="
"

IDX="0"

BASEDIR="/home/budsz/M-ONE"

# Move to basedir.
cd $BASEDIR

for URL in $LIST
do
    # Counter.
    IDX=$((IDX + 1))

    # Audio download.
    ## Stereo audio.
    yt-dlp --force-overwrites -f bestaudio -x --audio-format mp3 -o "aud-ori-$IDX.mp3" $URL

    # Random sleep (5 - 10) before continue.
    sleep $(shuf -i 5-10 -n 1)

    ## Mono audio.
    #yt-dlp --force-overwrites -x --audio-format mp3 --postprocessor-args "-ac 1" -o "aud-ori-$IDX.mp3" $URL

    # Download video clip.
    ## Default 22 for best video quality.
    yt-dlp --force-overwrites -f 22 -o "vid-ori-$IDX.mp4" $URL

    ## If failed, use 18 video quality.
    if [ $? -ne 0 ]; then
        yt-dlp --force-overwrites -f 18 -o "vid-ori-$IDX.mp4" $URL
    fi

    # Remove all audio from video.
    ffmpeg -y -i vid-ori-$IDX.mp4 -c copy -an vid-noaudio-$IDX.mp4

    # Random sleep (5 - 15) before continue.
    sleep $(shuf -i 5-15 -n 1)

done
