# WizDrobe

Flutter app for organizing clothing in a **wardrobe**, building **outfits** on a canvas from those photos, and browsing **saved outfit previews**. Runs on **web** (Chrome/Edge), **Android**, **iOS**, **Windows**, **macOS**, and **Linux**.

## Features

### Wizdrobe (wardrobe)
- Add items from **gallery** or **camera**. On **desktop web**, camera uses a **webcam** capture flow when you choose Camera (mobile file picker alone is not enough for live capture).
- Each item: **name**, **category** (tops, bottoms, shoes, outerwear, accessories), optional **AI background removal** via [remove.bg](https://www.remove.bg/) (transparent PNG).
- **API key**: set from the wardrobe header (**AI Key** / **AI On**). The key is stored locally with `shared_preferences`; there is no key bundled in the app.
- **Category chips** filter the grid with live counts.

### Create (outfit composer)
- **Blank canvas** inside a dashed frame; **Add from wardrobe** opens a sheet of your items—tap to place a copy on the canvas.
- **Tap** a piece to **select** it (blue border, brought to front). **Tap empty canvas** to deselect.
- **Drag** the photo or its label to **move** while selected.
- **Resize** with the blue corner handle while selected; **aspect ratio** comes from the image and is preserved (width drives height).
- **Long-press** the photo to remove it from the canvas (not the label).
- **Save** exports the canvas as a PNG and adds it to the **Outfits** tab for this session.

### Outfits
- Grid of **saved outfit previews** and names from the Create flow. Outfits (and wardrobe items) are **in memory** until you close the app; persistence can be added later.

### Settings
- App settings screen from the bottom navigation.

## Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A target device: **Chrome/Edge** (web), **Android** emulator/device, **iOS** simulator/device (macOS), or desktop.

### Install
```bash
flutter pub get
```

### Run
```bash
flutter run
```

Use a specific device:
```bash
flutter run -d chrome
flutter run -d edge
```

**Stable URL for web dev** (same port every time):
```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 7357
```
Then open `http://127.0.0.1:7357` in a browser.

### Optional: background removal
Add a remove.bg API key in the app (wardrobe screen) before using **Remove background**. Without a valid key, that step will fail with an API error.

## Tech stack
- **Flutter** (`image_picker`, `camera`, `http`, `shared_preferences`)
- Wardrobe / outfit models: `lib/wardrobe_models.dart`
- Outfit canvas & save: `lib/outfit_creator.dart`
- remove.bg client: `lib/background_removal_service.dart`
- Webcam UI (web + camera): `lib/webcam_capture_screen.dart`

## Tests
```bash
flutter analyze
flutter test
```

## Team
- Member A: [Name]
- Member B: [Name]
- Member C: [Name]
- Member D: [Name]
- Member E: [Name]
