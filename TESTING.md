# Testing (WizDrobe)

How to run **static analysis**, **unit/widget tests**, and **E2E (integration) tests** locally, what you need installed, and how that lines up with **GitHub Actions** CI.

## Prerequisites

| Tool | Notes |
|------|--------|
| **Flutter SDK** | Use a version compatible with this repo (CI pins **Flutter 3.41.5**; `pubspec.yaml` requires Dart **^3.11.4**). Run `flutter doctor` and fix any blocking issues for your targets. |
| **Chrome / Edge** (optional) | Only if you run web or pick a web device; see E2E notes below. |
| **Android SDK + emulator or device** (optional) | Only if you run integration tests **on Android** instead of the default host runner. |

From the **package root** (the directory that contains `pubspec.yaml`):

```bash
flutter pub get
```

## Lint / static analysis

Same as CI **Analyze** step:

```bash
flutter analyze
```

## Unit and widget tests

Tests live under `test/`. Matches CI **Unit and widget tests**:

```bash
flutter test test/
```

Run a single file:

```bash
flutter test test/theme_provider_test.dart
```

## E2E (integration tests)

Integration tests live under `integration_test/`. Matches CI **E2E (integration tests)**:

```bash
flutter test integration_test/
```

Or one file:

```bash
flutter test integration_test/golden_path_test.dart
```

### Device selection (local)

- **CI** runs these tests in a Linux container **without** prompting for a device (host / VM test binding).
- **Locally**, if Flutter asks you to choose a device, pick a **desktop** target (e.g. **Windows**) or run with `-d <device_id>` (`flutter devices` lists ids).  
- **Do not pick Chrome/Edge for integration tests**: Flutter reports that **web devices are not supported** for this integration-test flow; use a desktop or mobile device target instead.

The golden path test uses `WizdrobeApp(bypassImagePicker: true)` so it does not open the system gallery/camera.

## Coverage (optional)

From package root:

```bash
flutter test test/ --coverage
```

That writes `coverage/lcov.info`. **Line %** is not printed inside the file; summarize with **`lcov --summary coverage/lcov.info`** (install [LCOV](https://github.com/linux-test-project/lcov) if needed) or generate HTML with `genhtml`.

## How CI maps to these commands

Workflow file: **`.github/workflows/flutter.yml`** (workflow name: **Flutter CI**).

On every **pull request**, job **`Analyze and test`** (`flutter_checks`) runs:

| CI step | Local equivalent |
|---------|------------------|
| Install dependencies | `flutter pub get` |
| Analyze | `flutter analyze` |
| Unit and widget tests | `flutter test test/` |
| E2E (integration tests) | `flutter test integration_test/` |

**Tag pushes** run a separate job (**Build release APK**) for release builds; that is **not** the MR test pipeline.

## Troubleshooting

### Android: `INSTALL_FAILED_UPDATE_INCOMPATIBLE` (signatures do not match)

When you run integration tests against **Android** (`flutter test integration_test/ ...` with an Android device), Flutter may install a **debug** build. If the device already has another build of the same app id (**`com.example.wizdrobe`**) signed with a **different** key (e.g. an older release APK), install fails with *signatures do not match*.

**Fix:** uninstall the existing app from the emulator/device, then rerun tests:

```bash
adb uninstall com.example.wizdrobe
```

Or use **Android Studio → App info → Uninstall** for that package, then retry `flutter test integration_test/`.

---

*For product-level troubleshooting (install APK, remove.bg, blank screen), see **README.md**.*
