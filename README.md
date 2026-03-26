<div align="center">

<img src="docklock-smol.svg" width="72" height="72" alt="DockLock" />

# DockLock

**Keep your Dock where you put it.**

DockLock stops your Dock from jumping monitors every time your cursor grazes the bottom of the screen.

[**Website →**](https://timlenardo.github.io/docklock/)&nbsp;&nbsp;·&nbsp;&nbsp;[Download](#download)&nbsp;&nbsp;·&nbsp;&nbsp;[Support ♡](https://buy.stripe.com/00w6oG8d3bdDfFaaFt1B604)

</div>

---

## What it does

On macOS with multiple monitors, accidentally brushing the bottom of the wrong screen can cause your Dock to jump to that screen. It's happens all the time, and it's maddening.

Docklock fixes it. It quietly sits in your menu bar and prevents your Dock from jumping monitors.

**→ [Watch the demo](https://timlenardo.github.io/docklock/)**

## Features

- **Zero config** — install it, grant accessibility access, done
- **Lightweight** — just a menu bar icon, no bloat
- **Lock/Unlock** — easily unlock if you do want to move your Dock for some reason
- **Jump counter** — see how many accidental dock jumps it's prevented
- **Free** — pay what you want

## Download

Grab the latest `.dmg` from the [Releases](https://github.com/timlenardo/docklock/releases) page.

**Requirements:** macOS (Apple Silicon + Intel)

> DockLock needs Accessibility access to monitor cursor position. You'll be prompted on first launch.

## How it works

DockLock uses the macOS Accessibility API to watch cursor movement near screen edges. When it detects the cursor crossing the bottom boundary of a non-primary screen — a pattern that almost always triggers an accidental Dock migration — it intervenes before the Dock has a chance to jump.

The whole app is a single menu bar item. No settings to configure.

## Building from source

```bash
git clone https://github.com/timlenardo/docklock
cd docklock
open docklock.xcodeproj
```

Build and run from Xcode. Requires macOS 14+ SDK.

## Support

DockLock is free. If it saves your sanity, [buy me a coffee ♡](https://buy.stripe.com/00w6oG8d3bdDfFaaFt1B604)

---

<div align="center">Made by <a href="https://github.com/timlenardo">Tim Lenardo</a></div>
