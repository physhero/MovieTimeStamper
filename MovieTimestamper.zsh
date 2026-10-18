#!/bin/zsh

# 1. Locate bundled FFmpeg binaries
APP_RES_DIR="$(cd "$(dirname "$0")" && pwd)"
FFMPEG_BIN="$APP_RES_DIR/ffmpeg"
FFPROBE_BIN="$APP_RES_DIR/ffprobe"

chmod +x "$FFMPEG_BIN" "$FFPROBE_BIN" 2>/dev/null

# Fallback to local system paths if binaries are not bundled
if [ ! -x "$FFMPEG_BIN" ]; then
    export PATH="/opt/local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
    FFMPEG_BIN=$(which ffmpeg 2>/dev/null)
    FFPROBE_BIN=$(which ffprobe 2>/dev/null)
fi

# Fixed Blog Support URL
BLOG_URL="https://ed.or.kr/2026/10/18/movietimestamper01/"

# 2. Check Full Disk Access permission
if ! ls "$HOME/Library/Safari" >/dev/null 2>&1; then
    res=$(osascript -e 'button returned of (display dialog "⚠️ Full Disk Access is required to process videos.\n\n1. Click [Open Settings].\n2. Turn on the toggle switch for this app.\n3. Quit (Cmd+Q) and restart the app after enabling." buttons {"Ignore", "Open Settings"} default button "Open Settings" with title "Permission Required" with icon caution)')
    
    if [ "$res" = "Open Settings" ]; then
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        echo "Please grant permission in Settings, then relaunch the app."
        echo "PROGRESS:0"
        exit 0
    fi
fi

# 3. Idle state when launched without files
if [ $# -eq 0 ]; then
    echo "Ready! Drag and drop video files onto this window."
    echo "PROGRESS:0"
    exit 0
fi

# 4. Check FFmpeg binary availability
if [ -z "$FFMPEG_BIN" ] || [ ! -x "$FFMPEG_BIN" ]; then
    osascript -e 'display dialog "FFmpeg engine could not be found." buttons {"OK"} default button "OK" with icon stop'
    exit 1
fi

# Automatically open the Details drawer
osascript -e "
tell application \"System Events\"
    tell (first process whose unix id is $PPID)
        try
            if exists (button \"Details\" of window 1) then
                click button \"Details\" of window 1
            end if
        end try
    end tell
end tell" >/dev/null 2>&1 &

total_files=$#
current_file=0

echo ">>> Processing started: $total_files file(s) received"
echo ""

# 5. Process files sequentially
for f in "$@"; do
    current_file=$((current_file + 1))
    
    dir=$(dirname "$f")
    filename=$(basename "$f")
    base_name="${filename%.*}"
    ext="${filename##*.}"
    output="${dir}/${base_name}_timestamped.${ext}"

    echo "----------------------------------------"
    echo "[$current_file/$total_files] Processing: $filename"

    raw_time=$("$FFPROBE_BIN" -v error -show_entries format_tags=creation_time -of default=noprint_wrappers=1:nokey=1 "$f" | head -n 1 | tr -d '\r')

    epoch=""
    if [ -n "$raw_time" ]; then
        clean_time=$(echo "$raw_time" | sed -E 's/\.[0-9]+Z$|Z$//' | sed 's/ /T/')
        epoch=$(date -j -u -f "%Y-%m-%dT%H:%M:%S" "$clean_time" +%s 2>/dev/null)
        echo "  - Creation time (UTC): $clean_time"
    fi

    # Timezone adjustment (+9 hours for KST)
    if [[ "$epoch" =~ ^[0-9]+$ ]]; then
        epoch=$((epoch + 32400))
        echo "  - Adjusted epoch (KST): $epoch"
    else
        echo "  - No creation metadata: Using file creation date"
        epoch=$(stat -f %B "$f" 2>/dev/null || stat -f %m "$f")
        epoch=$((epoch - 32400))
    fi

    echo "  - Encoding..."

    ffmpeg_out=$("$FFMPEG_BIN" -y -i "$f" \
      -vf "drawtext=fontfile='/System/Library/Fonts/Menlo.ttc':text='%{pts\:gmtime\:$epoch}':fontcolor=white:fontsize=28:box=1:boxcolor=black@0.5:boxborderw=6:x=(w-text_w)/2:y=20" \
      -c:v h264_videotoolbox -pix_fmt yuv420p -b:v 5M -c:a copy "$output" 2>&1)
      
    if [ $? -ne 0 ]; then
        echo "  - [Error] Conversion failed!"
        echo "$ffmpeg_out"
        ERROR_LOG="$HOME/Desktop/FFmpeg_Error_Log.txt"
        echo "$ffmpeg_out" > "$ERROR_LOG"
        osascript -e 'display dialog "Conversion failed.\n\nPlease check FFmpeg_Error_Log.txt on your Desktop." buttons {"OK"} with icon stop'
        open "$ERROR_LOG"
        echo "Error occurred. Drag and drop files to try again."
        echo "PROGRESS:0"
        exit 1
    fi

    echo "  - Completed: $(basename "$output")"
    percent=$(( current_file * 100 / total_files ))
    echo "PROGRESS:$percent"
done

echo ""
echo "========================================"
echo "All files have been successfully processed."
echo "========================================"
echo "Ready! Drag and drop new files to start again."
echo "PROGRESS:100"

# 6. Completion dialog linking to blog
res=$(osascript -e 'button returned of (display dialog "All timestamps have been added successfully!" buttons {"Close", "Ask Questions / Support"} default button "Ask Questions / Support" with title "Complete" with icon note)')

if [ "$res" = "Ask Questions / Support" ]; then
    open "$BLOG_URL"
fi