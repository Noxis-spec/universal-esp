# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-11-02

### Added
- **Rayfield UI Library Integration** — Replaced the custom draggable button with a fully-featured, professional menu interface using the Rayfield library.
- **Interactive Toggles** — Users can now toggle specific ESP elements on the fly:
  - Enable/Disable ESP globally.
  - Show/Hide Player Names.
  - Show/Hide Health Bars.
  - Show/Hide Distance indicators.
  - Toggle Team Check (hides teammates).
- **Rayfield Callbacks** — The ESP rendering loop now dynamically reacts to UI changes without needing to reload the script.

### Changed
- Refactored the GUI creation entirely to use Rayfield's `CreateWindow` and `CreateToggle` methods.
- Optimized the rendering loop to check UI states (`SHOW_NAME`, `SHOW_HEALTH`, etc.) before updating UI elements, reducing unnecessary property changes.

### Removed
- Removed the custom-built `ScreenGui` and manual drag logic, as Rayfield handles window dragging and UI management automatically.

---

## [1.0.0] - 2026-11-02

### Added
- **Initial release** of Universal Mobile ESP.
- **2D Box ESP** — dynamic bounding boxes that scale based on player distance.
- **Health Bar** — visual health tracking with color gradient (Green to Red).
- **Name & Distance** — displays player names and distance in studs.
- **Team Check** — automatically hides teammates to prevent screen clutter.
- **Distance Culling** — stops rendering players beyond 500 studs to optimize performance on low-end mobile devices.
- **Mobile-Optimized UI** — compact, draggable ON/OFF toggle button that does not interfere with the movement joystick.