# ii - Custom Quickshell Dotfiles Config for Hyprland

> **Original Source**: Based on [end-4/dots-hyprland (`dots/.config/quickshell/ii`)](https://github.com/end-4/dots-hyprland/tree/main/dots/.config/quickshell/ii).

---

## Screenshots

|               Top Bar Media Pill & Lyrics               |                   Media Controls Popup Island                    |
| :-----------------------------------------------------: | :--------------------------------------------------------------: |
| ![Top Bar Preview](https://i.ibb.co/spGhyV43/image.png) | ![Media Island Preview](https://i.ibb.co/LX2zqgGn/qs-screen.png) |

---

## Key Modifications & New Features

Below is a breakdown of the enhancements and features introduced on top of the original `end-4/dots-hyprland` configuration.

### 1. 🎵 Real-Time Synchronized Lyrics

- **Precision 2-Stage Lyrics Lookup**: Uses exact track duration matching (`/api/get`) with smart scored fallback search (`/api/search`) to prevent live, acoustic, or remix version mismatches.
- **Instant In-Memory Lyrics Caching**: Caches fetched lyrics in memory during your session so repeated tracks or playlist loops load instantly with zero network requests.
- **Dynamic Pixel-Accurate Multiline Stitching**: Uses Qt native font measurement (`TextMetrics`) and dynamic bar width to stitch short phrases (`Line 1 • Line 2`) perfectly across **all languages & scripts** (English, Tamil, Malayalam, CJK, etc.) without overflowing the top bar.
- **Duration Proximity Grouping**: Intelligently stitches short consecutive ad-libs sung in quick succession (`gap <= 3.4s`) while respecting vocal pauses and instrumental breaks.
- **Live Preview & Clean Status**: Streams current lyrics directly to the top bar while showing upcoming lines inside the Media Controls popup, displaying clean status messages (`Fetching lyrics…` or `No lyrics`) exclusively for Spotify.

### 2. 🖥️ Interactive Top Bar & Media Controls Popup

- **Dynamic Top Bar Pill**:
  - Automatically switches between song info and live lyrics when playing music.
  - Smoothly scrolls long song titles or lyrics so nothing gets cut off.
  - Displays an inspirational quote (`"Everything happens for a reason"`) when no media is playing.
- **Media Controls Popup Island**:
  - **Smooth Looping Marquees**: Automatically scrolls long song titles, artists, and album names.
  - **Smooth Progress Bar**: Fluid seekbar animation with clear left/right time indicators.
- **Audio Wave Visualizer**:
  - Interactive wave animation embedded directly into the media pill that spans edge-to-edge with active rising bars smoothly curved along the pill's border radius.
- **Mouse & Scroll Wheel Gestures**:
  - **Left Click (Media Pill)**: Opens Media Controls popup (or Left Sidebar if no player is active).
  - **Right Click / Forward Button (Media Pill)**: Skip to next track.
  - **Back Button (Media Pill)**: Previous track.
  - **Middle Click (Media Pill)**: Play / Pause toggle.
  - **Double Click (Media Pill)**: Toggles Left Sidebar.
  - **Scroll Wheel (Left Side / Media Pill)**: Adjust audio volume.
  - **Scroll Wheel (Right Side / System Cluster)**: Adjust screen brightness.
- **Streamlined Layout (`BarContent.qml`)**:
  - **Left**: Interactive Spotify Media Pill & Live Lyrics.
  - **Center**: Workspace switcher (`Workspaces.qml`).
  - **Right**: Consolidated system cluster (Resources/Stats, Utility Buttons, Clock/Date + Weather, System Tray, and Right Sidebar toggle).

---

## Credits & Acknowledgements

- Original Quickshell configuration base by **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**.
- Synchronized lyrics provided via **[LRCLIB](https://lrclib.net/)**.
