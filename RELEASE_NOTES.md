# WizDrobe — Release notes

## Version 1.0.0 (Android)

**Google Play listing:** version **1.0.0** (version code **1**) — from `pubspec.yaml` `1.0.0+1`.

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

---

### Short copy (Play Store “What’s new” — ~500 characters)

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
