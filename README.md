# MovieTimeStamper 🕒🎬

🇺🇸 English | [🇰🇷 한국어](README_ko.md)

> **Standalone Video Timestamp Automator for macOS (Droplet Utility)**  
> Easily add precise creation date and time overlays to your videos by simply dragging and dropping them—no terminal commands or complicated software installations required.

[![Platform](https://img.shields.io/badge/Platform-macOS%20%28Apple%20Silicon%20%2F%20Intel%29-blue?logo=apple)]()
[![Engine](https://img.shields.io/badge/Engine-FFmpeg%20%28Bundled%29-green?logo=ffmpeg)]()
[![Support](https://img.shields.io/badge/Support-ed.or.kr-orange)](https://ed.or.kr/2026/10/18/movietimestamper01/)

---

## 📌 Features

* **Zero Dependency (Standalone Bundle)**  
  No need to install Homebrew, MacPorts, or FFmpeg. The app comes with static FFmpeg binaries bundled inside, so it works right out of the box.
* **Smart Metadata Extraction & Timezone Correction**  
  Uses `ffprobe` to read the video's standard `creation_time` (UTC) metadata and automatically adjusts it to Korean Standard Time (KST, UTC+9). Falls back to the file system's creation date if metadata is missing.
* **Hardware Acceleration (Apple Silicon / Intel)**  
  Leverages the macOS native `h264_videotoolbox` encoder for blazing-fast encoding with minimal CPU usage. (Includes `-pix_fmt yuv420p` to prevent errors with 10-bit and HDR videos).
* **Intuitive Droplet UI**  
  Supports batch processing. Drag and drop multiple videos onto the app window to encode them sequentially.
* **Automated Permission Check**  
  Checks for the required macOS 'Full Disk Access' permission on launch and provides a direct shortcut to the system settings if needed.
* **Clean Monospace Font Overlay**  
  Applies the system native `Menlo` font with a semi-transparent background box to prevent text jittering when the seconds change.

---

## 💻 System Requirements

* **OS**: macOS 11.0 (Big Sur) or later recommended.
* **Architecture**: Apple Silicon (M1/M2/M3/M4) and Intel x86_64.
* **Permissions**: System Settings > Privacy & Security > **Full Disk Access**.

---

## 🚀 Download & Installation

### 1. Download the App
Go to the **[Releases]** tab on the right sidebar, download the latest `MovieTimeStamper.zip`, and extract it.

### 2. Bypass "Unidentified Developer" Warning (First Launch Only)
Because this is an unsigned personal app, macOS may show a security warning.
* **Method A**: **Right-click (or Control-click)** the app icon, select **[Open]**, and click **[Open]** again in the dialog box.
* **Method B (Recommended)**: Open Terminal and remove the quarantine attribute:
  ```bash
  xattr -cr /path/to/MovieTimeStamper.app
  ```

### 3. Grant Full Disk Access
The app will prompt you for permissions on its first run.
1. Click **[Open Settings]** in the dialog prompt.
2. macOS will open `Privacy & Security > Full Disk Access`.
3. Turn **ON** the toggle for `MovieTimeStamper`. (If it's not listed, click the `+` button to add it).
4. Quit the app completely (`Command + Q`) and launch it again.

---

## 📖 How to Use

1. Launch `MovieTimeStamper.app`.
2. The progress window will display: `Ready! Drag and drop video files onto this window.`
3. Select your video files and **drag and drop them into the app window**.
4. The `Details` drawer will automatically expand, showing real-time encoding progress and metadata logs.
5. Once completed, the output files will be saved in the same folder as the originals with a `_timestamped.mp4` suffix.

---

## 🛠 Technical Workflow

```text
[Video Files Dropped] 
       │
       ▼
[ffprobe] Parse creation_time metadata
       │
       ├── Metadata exists: Parse UTC and add +32400 seconds (KST)
       └── No metadata: Fallback to macOS 'stat' file creation/modification date
       │
       ▼
[ffmpeg drawtext filter]
  - Font: /System/Library/Fonts/Menlo.ttc (28pt, White)
  - Background: Semi-transparent black box (Box Alpha 0.5)
  - Position: Top Center (x=(w-text_w)/2, y=20)
       │
       ▼
[Hardware Encoding]
  - Video Codec: h264_videotoolbox (Bitrate: 5Mbps, yuv420p)
  - Audio Codec: Copy original stream (-c:a copy)
       │
       ▼
[Completion Dialog & Support Link]
```

---

## ❓ Troubleshooting

* **The progress bar stops immediately after dropping a file.**  
  You likely haven't granted Full Disk Access. Turn the permission off and on again in System Settings, quit the app, and restart it.
* **A conversion failure dialog appears.**  
  Check the `FFmpeg_Error_Log.txt` file generated on your `~/Desktop`. This file contains the exact FFmpeg error output, which helps diagnose unsupported codecs or corrupted videos.

---

## 💬 Support & Feedback

For bug reports, feature requests, or general questions, please visit the official support blog post:

* **Official Support Page**: [https://ed.or.kr/2026/10/18/movietimestamper01/](https://ed.or.kr/2026/10/18/movietimestamper01/)

---

## 📄 License

* The wrapper script and UI packaging for this project are open-source and free to modify.
* The bundled **FFmpeg** and **ffprobe** binaries are licensed under the LGPL/GPL by the [FFmpeg project](https://ffmpeg.org/).