#!/usr/bin/dash
# IT Support & Development.
# Copyright (c) 2026, Studio Family Karaoke.
# All rights reserved.
#

WORKDIR="M-ONE"
BASEDIR="/home/`whoami`/$WORKDIR"
FFOPT="-hide_banner -nostdin -y"

# CD current work directory.
cd $BASEDIR

# Build filelist.
_FILES="$(find * -type f -name "*-vid-*")"

if [ -f "$_FILES" ]; then
    echo "${_FILES}" | while read -r FILES
    do
        # To definitively detect if a video uses a Constant Frame Rate (CFR)
        # Or a Variable Frame Rate (VFR).

        # If r_frame_rate matches avg_frame_rate exactly (e.g., both say 30/1), the video is likely CFR.
        # If they display different values (e.g., avg_frame_rate=29.97 but r_frame_rate=60/1), the video is VFR.

        _RAFR="$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate,avg_frame_rate -of default=noprint_wrappers=1 "$FILES")"
        _RFR="$(echo $_RAFR | awk '{print $1}' | cut -d = -f2)"
        _AFR="$(echo $_RAFR | awk '{print $2}' | cut -d = -f2)"

        if [ "$_RFR" != "$_AFR" ]; then
            _FPS="$(echo $_RFR | cut -d / -f1)"
            _TMPFILE="/tmp/$(uuidgen).mpg"

            ffmpeg $FFOPT -i "$FILES" -filter:v fps=fps=$_FPS "$_TMPFILE"
            mv -f "$_TMPFILE" "$FILES"
            echo " "
        else
            echo "$FILES: Skipped..."
        fi
    done
else
    echo "_FILES: Target is NULL."
fi

# CD home directory.
cd
