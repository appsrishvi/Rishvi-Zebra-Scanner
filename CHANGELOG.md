## 1.0.1

* Added `copyWith()` method to `ScanResult` for immutable updates.
* Added `==` operator and `hashCode` to `ScanResult` for value equality.
* Fixed `ScannerStatus` name extension to avoid conflict with Dart's built-in `.name` getter — renamed to `statusLabel`.
* Added `toString()` to `ScannerStatus` extension.
* Updated README screenshots to use stable `main` branch URLs.
* Minor documentation improvements.

## 1.0.0

* Initial release.
* Android support via Zebra DataWedge API.
* Stream-based scan result API (`scanResultStream`).
* Scanner status monitoring (`statusStream`).
* `initialize()`, `startScan()`, `stopScan()`, and `dispose()` methods.
* Type-safe `ScanResult` and `ScannerStatus` models.
