#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

# Site youtube downloader.
# https://ssvid.net/id/download-video-youtube-4

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
RANFN="$(tr -dc '0-9a-z' < /dev/urandom | head -c 7)"
_tmpfile="/tmp/$(basename $0 .sh)-$RANFN.tmp"

# CD Basedir.
cd $BASEDIR

# Generate filelist.
find * -maxdepth 0 -type f -name "*.mp4" ! -name "*-vid-*" > $_tmpfile

# Main processing.
while read -r FILES
do
    # Stripping filename extension.
    SFILES="$(echo "$FILES" | sed 's/.mp4$//')"

    # Extract audio from video.
    ffmpeg -hide_banner -nostdin -y -i "$FILES" -map 0:a -b:a 192K "d-aud-$SFILES.mp3"

    # Remove all audio from video.
    ffmpeg -hide_banner -nostdin -y -i "$FILES" -c copy -an "d-vid-$SFILES.mp4"
done < $_tmpfile

# Remove ${_tmpfile}.
rm -f $_tmpfile
