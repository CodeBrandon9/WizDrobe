# WizDrobe

Flutter app for organizing clothing in a **wardrobe**, building **outfits** on a canvas from those photos, and browsing **saved outfit previews**. Runs on **web** (Chrome/Edge), **Android**, **iOS**, **Windows**, **macOS**, and **Linux**.

## Install (Android APK from GitHub)

**WizDrobe** is a closet companion app: photograph your clothes, organize them by category, compose outfits on a canvas, and browse saved outfit images—optionally with AI background removal when you add your own remove.bg API key.

### Download and install

1. Get the APK in either place: **[Releases](https://github.com/CodeBrandon9/WizDrobe/releases)** (if a maintainer attached the APK), or **[Actions](https://github.com/CodeBrandon9/WizDrobe/actions)** → open the **Flutter CI** run for your tag → **Artifacts** → download **`app-release-…`** (a ZIP containing `app-release.apk`).
2. Unzip if needed, then use the **`.apk`** file.
3. On your phone, transfer the APK if you downloaded it on a computer (USB, cloud drive, email, etc.).
4. Open the APK file (usually from **Files** or your **Downloads** app).
5. If Android blocks installation: go to **Settings → Apps → Special app access → Install unknown apps** (wording varies by manufacturer), choose the app you used to open the APK (e.g. **Chrome** or **Files**), and allow **Install unknown apps**. Then open the APK again and confirm **Install**.

   In short: **download the APK** (Releases or Actions artifact) → **allow “Install unknown apps”** for your browser or file manager → **open the APK** to install.

This flow is for sideloading the GitHub-built APK, not the Google Play Store.

### System requirements

| Platform | Notes |
|----------|--------|
| **Android** | **Phone or tablet**; **API level** matches the Flutter default for this project (typically **Android 5.0, API 21+**—check `minSdk` in `android/app/build.gradle.kts` if you need the exact value). A camera helps for taking photos; gallery-only use is fine. |
| **iOS** | There is **no APK** for iPhone/iPad. Use a **development build**, **TestFlight**, or **App Store** if your team ships an iOS binary separately. |

### First use (golden path)

1. Launch **WizDrobe** and use the bottom navigation to open **Wizdrobe** (wardrobe).
2. Add at least one item: **Gallery** or **Camera**, then set a **name** and **category** (tops, bottoms, shoes, outerwear, accessories).
3. *(Optional)* Turn **AI On** and paste your **remove.bg** API key in the header if you want **Remove background** on an item.
4. Open **Create**: tap **Add from wardrobe**, choose an item to place it on the canvas; **tap** to select, **drag** to move, use the **corner handle** to resize; **long-press** the photo to remove it from the canvas.
5. Tap **Save** to export the outfit image and send it to the **Outfits** tab.
6. Open **Outfits** to see saved previews for this session.

> **Screenshots:** Add images here for wardrobe grid, Create canvas with a selected item, and Outfits grid (replace this callout when assets are available).

### Backend and sign-in

- There is **no app account**, **Google sign-in**, or **team backend** in this build. Wardrobe and outfits stay **on the device for the current session** (data is cleared when you fully close the app unless you add persistence later).
- The only **network** feature is optional **remove.bg** background removal: when you use it, the app calls **remove.bg’s API** over HTTPS with **your** API key (stored locally). No WizDrobe server is involved.

### Troubleshooting

| Issue | What to try |
|--------|-------------|
| **App won’t install on Android** | Enable **Install unknown apps** for the browser or file app you used (see Download and install). Uninstall any older conflicting build with the same package name if the installer reports a conflict. |
| **“Remove background” or AI fails** | Confirm **AI Key** is set and **AI On** is enabled; check **Wi‑Fi/mobile data**; verify your remove.bg key and quota at [remove.bg](https://www.remove.bg/). |
| **Blank or stuck screen on launch** | Force-stop the app and reopen. If you only see a white screen after granting permissions, restart the app once. (If you later add a login screen, add **internet** and account checks here.) |
| **Data disappeared** | Expected in v1.x: items and outfits are **in-memory** until you close the app. |

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

## Setup (developers)

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A target device: **Chrome/Edge** (web), **Android** emulator/device, **iOS** simulator/device (macOS), or desktop.

### Dependencies
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
- Member A: Brandon Thibodeaux
- Member B: Scott Whitman
- Member C: Megan Moss
- Member D: Madison Ledg
- Member E: Seth Nunez
