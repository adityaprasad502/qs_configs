<div align="center">

# ii ✦

**A customized Quickshell configuration for Hyprland, based on [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland).**

</div>

> **⚠ Heads up** — this repo is for people who know what they're doing. It is not a plug-and-play dotfile setup: no installer, no hand-holding, and no guarantee it works on your system out of the box.  
> **Note:** This README won't be updated further. Please follow the commits from the last README update for new features and changes. You can view all changes made since this document was frozen [here](https://github.com/adityaprasad502/qs_configs/compare/946118a...master).

## Showcase

<table>
<tr><td align="center">

https://github.com/user-attachments/assets/c21bf387-9bf7-4a87-a946-a175f3ebebc2

*The bar with live lyrics, media pill & popups in action.*

</td></tr>
</table>

## Features

- **Live synced lyrics** — current line displayed in the top bar while music plays, with upcoming lines in the media popup. Includes session-wide caching, smart repeat collapsing (`x3`), countdown timers for instrumental gaps, and a graceful indicator for unsynced tracks.
- **Interactive media pill** — marquee-scrolling song info, a smooth seekbar, click / middle-click / side-button controls for play, skip and sidebar, plus an edge-to-edge audio wave visualizer that reacts to playback.
- **Network awareness** — live upload/download speed meters on the bar, with a redesigned status popup showing interface details, Wi-Fi signal and connectivity state.
- **KDE Connect integration** — dual battery pills for your laptop and phone, with dynamically adapting popups tracking live charging rates, peak speeds, session gains, and ETAs. Supports multiple connected phones seamlessly.
- **Reworked workspaces** — an overhauled workspace switcher, alongside unified `StatCard`-based popups for system resources (CPU / GPU / RAM / disk).
- **Material squircles** — a custom shape rendering library powering smooth, consistent widget corners across the shell.
- **NextDNS quick toggle** — replaces the upstream Cloudflare WARP toggle; starts/stops the `nextdns` daemon with live status sync (hidden entirely if the CLI isn't installed).
- **Performance tuned** — aggressive debounce timers, strictly event-driven services (no polling), and lazy-loaded sidebar/popup components to minimize idle CPU and RAM usage.

> [!TIP]
> **How this fork differs**
> The first commit was a straight copy of the upstream config. Everything listed above — the lyrics system, media pill, network widgets, KDE Connect support, workspaces, resource popups, the shapes library, and the NextDNS toggle — was added or reworked on top of it.

## Installation

Requires [Quickshell](https://quickshell.outfoxxed.me/) and Hyprland, along with the same dependencies as the upstream config.

```sh
git clone https://github.com/adityaprasad502/qs_configs ~/.config/quickshell/ii
qs -p ~/.config/quickshell/ii
```

If something breaks, you're expected to read the QML and fix it yourself.

## Credits

- Base config by **[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)**
- Lyrics powered by **[LRCLIB](https://lrclib.net/)**
