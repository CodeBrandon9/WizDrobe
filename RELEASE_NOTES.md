# WizDrobe — Release notes

## Version 1.1.0 (Android)

### What is included in main (1.1.0)

This release includes all updates currently merged into `main`, with a major focus on app personalization and UI consistency.

**Settings and personalization**

- New `ThemeProvider` architecture for centralized app theming.
- Choose from multiple **color schemes** and apply them across the app.
- Toggle **Dark Mode** from Settings.
- Pick a **font family** (Google Fonts integration).
- Select **Wardrobe layout mode**: Grid (2 columns), Grid (3 columns), or List.
- Theme and layout preferences are persisted locally with `shared_preferences`.

**UI and UX improvements**

- Updated visual styling across navigation, wardrobe, create flow, and settings for better consistency.
- Improved dark-mode aware colors in key surfaces and controls.
- Added user feedback snackbars for theme/layout changes and key actions.

**Technical updates**

- Added `google_fonts` dependency and related lockfile updates.
- Platform generated plugin files refreshed for desktop targets.

### Notes

- There is still no WizDrobe backend or account system in this release.
- Wardrobe items and outfits remain session-local/in-memory unless persistence is added later.

---

## Version 1.0.0 (Android)

### What’s new in 1.0.0

Initial public release of WizDrobe: organize your clothes, design outfits on a canvas, and browse saved looks.

**Wardrobe**

- Add clothing photos from your gallery or camera.
- Name each item and assign a category: tops, bottoms, shoes, outerwear, or accessories.
- Filter your wardrobe with category chips and live counts.
- Optional **AI background removal** (remove.bg): turn photos into transparent PNGs. Add your own API key in the app (**AI Key** / **AI On** in the wardrobe header); keys stay on your device.

**Create**

- Build outfits on a blank canvas inside a frame.
- Pull pieces from your wardrobe onto the canvas; tap to select, drag to move, resize with the corner handle (aspect ratio preserved).
- Long-press a photo to remove it from the canvas.
- Save the canvas as an image and add it to your **Outfits** collection for this session.

**Outfits**

- Grid of saved outfit previews and names from Create.

**Settings**

- App settings available from the bottom navigation.

### Notes

- Wardrobe and outfits are kept **in memory** for this release; closing the app clears session data unless you add persistence in a future update.
- Background removal requires a valid remove.bg key and network access.

### Install the built APK on an emulator or device (Android Studio)

1. Open Android Studio and start an emulator from **Device Manager**, or connect a physical Android phone with **USB debugging** enabled.
2. Use the built APK at `build/app/outputs/flutter-apk/app-release.apk`.
3. Install it with either method:
   - **Drag and drop** `app-release.apk` onto the running emulator window, or
   - Use terminal:
     ```bash
     adb devices
     adb install -r "build/app/outputs/flutter-apk/app-release.apk"
     ```
4. Open **WizDrobe** on the emulator/device.

---

### Short copy (“What’s new” — ~500 characters)

```
WizDrobe 1.0.0 — first release!

• Build a digital wardrobe from camera or gallery photos
• Categories, filters, and optional remove.bg background removal (bring your API key)
• Compose outfits on a canvas: place, move, resize, and save previews
• Browse saved outfits and adjust settings from the tab bar

Session-only storage in v1.0.0 — data resets when you close the app.
```

### Ultra-short (if character limit is tight)

```
First release: wardrobe with categories & optional AI cutouts, outfit canvas with save to Outfits, and settings. Session-only until a future update.
```
