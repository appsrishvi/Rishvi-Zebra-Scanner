# Zebra Scanner Plugin - Usage Guide

## Quick Start

This guide shows you how to use the Zebra Scanner Plugin in your Flutter app.

## Step 1: Import the Plugin

```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';
```

## Step 2: Initialize the Scanner

Call this once when your app starts or when you need the scanner:

```dart
await ZebraScanner.initialize();
```

## Step 3: Add Listeners

### Listen to Scan Results

```dart
ZebraScanner.scanResultStream.listen((ScanResult result) {
  print('Barcode: ${result.data}');
  print('Type: ${result.type}');
  print('Time: ${result.timestamp}');
});
```

### Listen to Status Changes

```dart
ZebraScanner.statusStream.listen((ScannerStatus status) {
  switch (status) {
    case ScannerStatus.ready:
      print('Scanner is ready');
      break;
    case ScannerStatus.scanning:
      print('Scanner is scanning');
      break;
    case ScannerStatus.error:
      print('Scanner error');
      break;
    default:
      break;
  }
});
```

## Step 4: Control Scanning

### Start Scanning

```dart
await ZebraScanner.startScan();
```

### Stop Scanning

```dart
await ZebraScanner.stopScan();
```

## Step 5: Clean Up

When you're done with the scanner:

```dart
ZebraScanner.dispose();
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

class MyScanner extends StatefulWidget {
  @override
  State<MyScanner> createState() => _MyScannerState();
}

class _MyScannerState extends State<MyScanner> {
  String lastBarcode = '';
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupScanner();
  }

  Future<void> _setupScanner() async {
    // Initialize
    await ZebraScanner.initialize();

    // Listen to results
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        lastBarcode = result.data;
        isScanning = false;
      });
    });

    // Listen to status
    ZebraScanner.statusStream.listen((status) {
      setState(() {
        isScanning = status == ScannerStatus.scanning;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Last Scan: $lastBarcode'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isScanning ? null : () => ZebraScanner.startScan(),
              child: Text('Start Scan'),
            ),
            ElevatedButton(
              onPressed: isScanning ? () => ZebraScanner.stopScan() : null,
              child: Text('Stop Scan'),
            ),
          ],
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

## Key Points

1. **Always initialize first**: Call `initialize()` before using other methods
2. **Use streams**: Listen to `scanResultStream` for scan results
3. **Check status**: Monitor `statusStream` to know scanner state
4. **Clean up**: Call `dispose()` when done
5. **Error handling**: Wrap calls in try-catch blocks

## Common Patterns

### Auto-start scanning after initialization

```dart
await ZebraScanner.initialize();
await ZebraScanner.startScan();
```

### Toggle scanning

```dart
if (ZebraScanner.currentStatus == ScannerStatus.scanning) {
  await ZebraScanner.stopScan();
} else {
  await ZebraScanner.startScan();
}
```

### Check if initialized

```dart
if (ZebraScanner.isInitialized) {
  await ZebraScanner.startScan();
} else {
  await ZebraScanner.initialize();
}
```

## Error Handling

```dart
try {
  await ZebraScanner.initialize();
} catch (e) {
  print('Failed to initialize: $e');
}

try {
  await ZebraScanner.startScan();
} catch (e) {
  print('Failed to start scan: $e');
}
```

## Testing

To test the plugin:

1. Run the app on a Zebra device
2. Click "Initialize" button
3. Click "Start Scan" button
4. Point the scanner at a barcode
5. The result will appear in the UI

## Need Help?

Check the example app in `lib/example_app.dart` for a complete working implementation.
