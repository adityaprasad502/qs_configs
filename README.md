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

- **Live Spotify Lyrics**: Automatically fetches and displays real-time synchronized lyrics for Spotify tracks.
- **Smart Line Pairing**: Seamlessly groups short lyric lines into natural phrases without overlapping or repeating lines, supporting both English and international languages.
- **Live Preview**: Streams current lyrics directly to the top bar while showing the upcoming lyric line inside the Media Controls popup.
- **Clean Status Display**: Shows helpful status messages (`Fetching lyrics…` or `No lyrics`) for Spotify tracks, while keeping YouTube videos and other media players clean and uncluttered.

### 2. 🖥️ Interactive Top Bar & Media Controls Popup

- **Dynamic Top Bar Pill**:
  - Automatically switches between song info and live lyrics when playing music.
  - Smoothly scrolls long song titles or lyrics so nothing gets cut off.
  - Displays an inspirational quote (`"Everything happens for a reason"`) when no media is playing.
- **Media Controls Popup Island**:
  - **Smooth Looping Marquees**: Automatically scrolls long song titles, artists, and album names.
  - **Smooth Progress Bar**: Fluid seekbar animation with clear left/right time indicators.
- **Audio Wave Visualizer**:
  - Interactive wave animation embedded directly into the media pill that reacts dynamically to your music.
- **Mouse Gestures**:
  - **Left Click**: Opens Media Controls popup (or Left Sidebar if no player is active).
  - **Double Click**: Toggles Left Sidebar.
  - **Middle Click**: Play / Pause toggle.
- **Streamlined Layout (`BarContent.qml`)**:
  - **Left**: Interactive Spotify Media Pill & Live Lyrics.
  - **Center**: Workspace switcher (`Workspaces.qml`).
  - **Right**: Consolidated system cluster (Resources/Stats, Utility Buttons, Clock/Date + Weather, System Tray, and Right Sidebar toggle).

---

## Credits & Acknowledgements

- Original Quickshell configuration base by **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**.
- Synchronized lyrics provided via **[LRCLIB](https://lrclib.net/)**.
