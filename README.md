# Universal Mobile ESP

A clean, lightweight, and fast ESP for mobile Roblox (Delta, Arceus X, Codex, Fluxus). Built specifically for phones to ensure zero lag and stable FPS. Shows players through walls, perfect for PvP and survival games.

---

## Features

- **2D Box ESP** — Clean bounding boxes around players that scale dynamically based on distance.
- **Health Bar** — Real-time health tracking with a color gradient (Green to Red).
- **Name & Distance** — Displays the player's name and exact distance in studs.
- **Team Check** — Automatically hides teammates to keep your screen clean.
- **Distance Culling** — Stops rendering ESP for players further than 500 studs to save device resources.
- **Mobile Optimized UI** — A compact `ESP: ON/OFF` button that can be dragged anywhere on the screen so it never blocks your movement joystick.

---

## How to Use

1. Copy the code from the `main.lua` file.
2. Paste it into your executor (Delta, Arceus X, etc.).
3. Press Execute.
4. The ESP will turn on automatically. You can drag the button around the screen.

**Quick load:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Noxis-spec/universal-esp/main/main.lua"))()

## Roadmap

- [ ] Tracers (lines from the bottom of the screen to the player).
- [ ] Skeleton ESP (rendering character bones).
- [ ] Chams (glowing models through walls).
- [ ] Customizable color themes in the UI.

---

## License

MIT License. Free to modify, distribute, and build upon.

Developed by **Noxis-spec**