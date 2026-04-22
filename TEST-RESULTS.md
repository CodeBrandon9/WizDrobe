# Test results & CI summary (short)

Snapshot derived from the **committed** `coverage/lcov.info` (line totals) and **current** `test/` + `integration_test/` sources. **Re-run locally** after big changes; **paste your latest green GitHub Actions run** where noted.

## Approximate counts

| Kind | Count |
|------|------:|
| Unit / widget test **files** (`test/`) | 4 |
| Integration / E2E test **files** (`integration_test/`) | 1 |
| Unit / widget **cases** (rough: `test(` / `testWidgets(`) | ~18 |
| E2E **cases** | 1 (golden path) |
| **Total** automated cases (order of magnitude) | **~19** |

## Line coverage (from `coverage/lcov.info`)

Aggregated across all `LF:` / `LH:` records in the committed report:

| Metric | Value |
|--------|------:|
| Lines found (`LF` sum) | 1,023 |
| Lines hit (`LH` sum) | 434 |
| **Approx. line coverage** | **~42.4%** |

Per-file detail is in `coverage/lcov.info` (each block ends with `LF:` / `LH:` for that source). Large UI in `lib/main.dart` is mostly under-exercised by unit/widget tests unless you add more tests or exclude paths in reports.

**Refresh coverage:**

```bash
flutter test test/ --coverage
# optional: lcov --summary coverage/lcov.info
```

## CI (Flutter CI)

| Step | Command |
|------|---------|
| Analyze | `flutter analyze` |
| Unit / widget | `flutter test test/` |
| E2E | `flutter test integration_test/` |

Workflow: [`.github/workflows/flutter.yml`](.github/workflows/flutter.yml) — on GitHub: **Actions** → **Flutter CI**.

## Last green pipeline (fill in)

**Link:** _&lt;replace with e.g. `https://github.com/<org>/<repo>/actions/runs/<run_id>`&gt;_

**Screenshot:** _&lt;optional: attach or link to team drive&gt;_

---

_Tip: after each green PR merge, update the link above (or replace this file with an export from your CI dashboard if your course requires it)._
