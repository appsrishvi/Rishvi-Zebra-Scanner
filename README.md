# rishvi_zebra_scanner

[![pub.dev](https://img.shields.io/pub/v/rishvi_zebra_scanner.svg)](https://pub.dev/packages/rishvi_zebra_scanner)
[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue.svg)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-API%2023%2B-green.svg)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

![Banner](https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/banner.png)

A Flutter plugin for **[Zebra Technologies](https://www.zebra.com)** barcode scanner devices.
Uses the Zebra **DataWedge API** to deliver scan results to your Flutter app via a reactive stream.

Developed by **[Rishvi](https://rishvi.co.uk)** — Linnworks Certified Partners, specialising in
warehouse management and Zebra hardware integrations.

> **Android only** — designed for Zebra Android devices with DataWedge pre-installed.

---

## Screenshots

<div style="overflow-x: auto; white-space: nowrap; padding: 8px 0;">
  <img src="https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/1.png" width="150" style="display:inline-block; margin-right:8px; border-radius:8px;" />
  <img src="https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/2.png" width="150" style="display:inline-block; margin-right:8px; border-radius:8px;" />
  <img src="https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/3.png" width="150" style="display:inline-block; margin-right:8px; border-radius:8px;" />
  <img src="https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/4.png" width="150" style="display:inline-block; margin-right:8px; border-radius:8px;" />
  <img src="https://raw.githubusercontent.com/appsrishvi/Rishvi-Zebra-Scanner/9491cfc1705ddb2a48ca4c78dc8056241841783c/screenshot/5.png" width="150" style="display:inline-block; border-radius:8px;" />
</div>

---

## About Zebra Devices

[Zebra Technologies](https://www.zebra.com) manufactures enterprise-grade Android mobile computers
and barcode scanners used in warehouses, retail, logistics, and healthcare. Popular device families include:

| Family | Example Models | Use Case |
|---|---|---|
| TC-series | TC21, TC26, TC52, TC57, TC72, TC77 | Warehouse / field mobility |
| MC-series | MC2200, MC3300, MC9300 | Retail / inventory |
| EC-series | EC30, EC50, EC55 | Enterprise compact |
| WT-series | WT6300 | Wearable / hands-free |

All Zebra Android devices ship with **DataWedge** — Zebra's built-in barcode scanning middleware.
This plugin communicates with DataWedge via broadcast intents, so no USB or Bluetooth pairing is needed.

---

## How It Works

```
Zebra Device Hardware Trigger / Soft Trigger
        │
        ▼
  Zebra DataWedge (built-in middleware)
        │  broadcast intent
        ▼
  ZebraScannerPlugin (native Android)
        │  MethodChannel
        ▼
  ZebraScanner (Dart API)
        │  Stream<ScanResult>
        ▼
  Your Flutter App
```

1. Your app calls `ZebraScanner.initialize()` — the plugin creates a DataWedge profile scoped to your app.
2. When a barcode is scanned (hardware trigger or `startScan()`), DataWedge broadcasts the result.
3. The plugin receives the broadcast and pushes a `ScanResult` onto `scanResultStream`.
4. Your Flutter UI reacts to the stream.

---

## Installation

### 1. Add the dependency

```yaml
dependencies:
  rishvi_zebra_scanner: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 2. Fix manifest merge conflict (if needed)

If you see a build error about `android:label`, add `tools:replace="android:label"` to
`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <application
        android:label="your_app_name"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        tools:replace="android:label">
        ...
    </application>
</manifest>
```

### 3. No other setup needed

- The Zebra BarcodeScannerLibrary AAR is **bundled inside the plugin** — no manual Gradle changes.
- The plugin **self-registers** via Flutter's v2 embedding — no `MainActivity` changes.
- DataWedge profile `ZebraFlutterProfile` is **created automatically** on first `initialize()`.

---

## Quick Start

```dart
import 'package:rishvi_zebra_scanner/zebra_scanner_plugin.dart';

// 1. Initialize once (e.g. in initState)
await ZebraScanner.initialize();

// 2. Listen for scan results
ZebraScanner.scanResultStream.listen((ScanResult result) {
  print('Barcode : ${result.data}');
  print('Type    : ${result.type}');      // e.g. EAN-13, QR Code, Code 128
  print('Time    : ${result.timestamp}');
});

// 3. Trigger a soft scan (same as pressing the hardware trigger)
await ZebraScanner.startScan();

// 4. Stop scanning
await ZebraScanner.stopScan();

// 5. Clean up when done
ZebraScanner.dispose();
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:rishvi_zebra_scanner/zebra_scanner_plugin.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _barcode = 'Point scanner at a barcode';
  ScannerStatus _status = ScannerStatus.uninitialized;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();

    ZebraScanner.scanResultStream.listen((result) {
      setState(() => _barcode = result.data);
    });

    ZebraScanner.statusStream.listen((status) {
      setState(() => _status = status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _status == ScannerStatus.ready;
    final isScanning = _status == ScannerStatus.scanning;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Zebra Scanner')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status indicator
                Chip(
                  label: Text(_status.name.toUpperCase()),
                  backgroundColor: isReady
                      ? Colors.green.shade100
                      : isScanning
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                ),
                const SizedBox(height: 32),
                // Last scan result
                Text(
                  _barcode,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isReady ? () => ZebraScanner.startScan() : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isScanning ? () => ZebraScanner.stopScan() : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}
```

---

## API Reference

### ZebraScanner

| Method / Property | Returns | Description |
|---|---|---|
| `initialize()` | `Future<bool>` | Creates the DataWedge profile and registers the scan receiver. Call once before scanning. |
| `startScan()` | `Future<bool>` | Fires the soft scan trigger — same as pressing the hardware button. |
| `stopScan()` | `Future<bool>` | Stops the soft scan trigger. |
| `dispose()` | `void` | Closes streams and releases all resources. |
| `scanResultStream` | `Stream<ScanResult>` | Emits a `ScanResult` on every successful scan. |
| `statusStream` | `Stream<ScannerStatus>` | Emits `ScannerStatus` changes. |
| `currentStatus` | `ScannerStatus` | The current scanner status. |
| `isInitialized` | `bool` | Whether `initialize()` has been called successfully. |

### ScanResult

| Property | Type | Description |
|---|---|---|
| `data` | `String` | The decoded barcode value. |
| `type` | `String?` | Barcode symbology — e.g. `EAN-13`, `QR Code`, `Code 128`. |
| `timestamp` | `DateTime` | When the scan occurred. |
| `source` | `String?` | Scan source — e.g. `barcode_scan`. |

### ScannerStatus

| Value | Description |
|---|---|
| `uninitialized` | `initialize()` has not been called yet. |
| `ready` | Scanner is idle and ready to scan. |
| `scanning` | Scan trigger is active. |
| `error` | An error occurred — check logcat. |
| `disabled` | Scanner disabled by DataWedge policy. |

---

## Requirements

| Requirement | Value |
|---|---|
| Flutter SDK | ≥ 3.0.0 |
| Dart SDK | ≥ 3.0.0 |
| Android API | 23+ (Android 6.0+) |
| Device | Zebra Android device with DataWedge |

---

## Supported Zebra Devices

Any Zebra Android device with DataWedge installed. Tested on:
- TC52, TC57, TC72, TC77 (TC-series)
- MC3300, MC9300 (MC-series)
- EC50, EC55 (EC-series)

For the full Zebra device catalogue visit [zebra.com](https://www.zebra.com).

---

## Supported Barcode Symbologies

All symbologies supported by Zebra DataWedge:

| 1D | 2D |
|---|---|
| Code 39, Code 128, Code 93 | QR Code, Data Matrix |
| EAN-8, EAN-13 | PDF417, Aztec |
| UPC-A, UPC-E | MaxiCode, DotCode |
| Interleaved 2 of 5, Codabar | MicroQR, MicroPDF |

---

## Troubleshooting

**Scanner not initializing**
- Confirm DataWedge is installed: `Settings > Apps > DataWedge`
- Check logcat: `adb logcat | grep ZebraScanner`

**No scan results received**
- Ensure `initialize()` was called before `startScan()`
- Open the DataWedge app and confirm `ZebraFlutterProfile` exists and is enabled
- Confirm the profile's Intent output action is `com.symbol.datawedge.api.RESULT`

**Build error: Manifest merger failed on `android:label`**
- Add `tools:replace="android:label"` to your `<application>` tag — see [Installation step 2](#2-fix-manifest-merge-conflict-if-needed)

**Build error: Could not resolve `com.zebra:barcode-scanner-library`**
- Run `flutter clean && flutter pub get` and rebuild
- The plugin injects its Maven repo automatically — no manual Gradle changes needed

---

## Project Structure

```
lib/
├── zebra_scanner_plugin.dart     # Public API — import this
└── src/
    ├── zebra_scanner.dart        # ZebraScanner class
    └── models/
        ├── scan_result.dart      # ScanResult model
        └── scanner_status.dart   # ScannerStatus enum

android/
├── src/main/kotlin/com/zebra_scanner/
│   └── ZebraScannerPlugin.kt    # Native plugin (auto-registered, no MainActivity needed)
├── maven/                        # Bundled Zebra BarcodeScannerLibrary AAR
└── build.gradle.kts

example/                          # Example app — 4 working demos
```

---

## License

MIT — see [LICENSE](LICENSE)

---

## About

### Zebra Technologies

[Zebra Technologies](https://www.zebra.com) is the world's leading manufacturer of enterprise
barcode scanners, mobile computers, and label printers. Zebra devices run Android and ship with
**DataWedge** — a powerful scanning middleware that handles all hardware scanner communication.

This plugin bridges Zebra's DataWedge API with Flutter, so you can build warehouse, retail,
and logistics apps using Flutter on Zebra hardware.

### Rishvi

**[Rishvi](https://rishvi.co.uk)** is a UK-based Linnworks Certified Partner specialising in:
- Flutter plugin development for Zebra hardware
- Linnworks custom integrations and scripting
- Warehouse management and e-commerce IT solutions

🌐 [rishvi.co.uk](https://rishvi.co.uk)
