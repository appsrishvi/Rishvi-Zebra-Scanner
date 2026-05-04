# Zebra Scanner Plugin - Quick Reference

## Import

```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';
```

## Initialize

```dart
await ZebraScanner.initialize();
```

## Listen to Scans

```dart
ZebraScanner.scanResultStream.listen((result) {
  print(result.data);  // Barcode data
});
```

## Listen to Status

```dart
ZebraScanner.statusStream.listen((status) {
  print(status);  // Scanner status
});
```

## Start Scanning

```dart
await ZebraScanner.startScan();
```

## Stop Scanning

```dart
await ZebraScanner.stopScan();
```

## Check Status

```dart
if (ZebraScanner.currentStatus == ScannerStatus.ready) {
  // Ready to scan
}
```

## Check Initialized

```dart
if (ZebraScanner.isInitialized) {
  // Scanner is ready
}
```

## Clean Up

```dart
ZebraScanner.dispose();
```

## Complete Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcode = '';

  @override
  void initState() {
    super.initState();
    ZebraScanner.initialize();
    ZebraScanner.scanResultStream.listen((result) {
      setState(() => barcode = result.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Barcode: $barcode'),
              ElevatedButton(
                onPressed: () => ZebraScanner.startScan(),
                child: Text('Scan'),
              ),
            ],
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

## ScanResult Properties

```dart
result.data       // String - barcode data
result.type       // String? - barcode type
result.timestamp  // DateTime - when scanned
result.source     // String? - scan source
```

## ScannerStatus Values

```dart
ScannerStatus.uninitialized  // Not initialized
ScannerStatus.ready          // Ready to scan
ScannerStatus.scanning       // Currently scanning
ScannerStatus.error          // Error occurred
ScannerStatus.disabled       // Scanner disabled
```

## Error Handling

```dart
try {
  await ZebraScanner.initialize();
} catch (e) {
  print('Error: $e');
}
```

## Common Patterns

### Toggle Scan

```dart
void toggleScan() {
  if (ZebraScanner.currentStatus == ScannerStatus.scanning) {
    ZebraScanner.stopScan();
  } else {
    ZebraScanner.startScan();
  }
}
```

### Auto-Initialize

```dart
@override
void initState() {
  super.initState();
  _initScanner();
}

Future<void> _initScanner() async {
  await ZebraScanner.initialize();
  await ZebraScanner.startScan();
}
```

### Collect Multiple Scans

```dart
List<String> scans = [];

ZebraScanner.scanResultStream.listen((result) {
  setState(() {
    scans.add(result.data);
  });
});
```

## Tips

1. Always initialize before scanning
2. Use streams for real-time updates
3. Dispose when done
4. Handle errors with try-catch
5. Check status before operations

## See Also

- `PLUGIN_USAGE_GUIDE.md` - Detailed usage guide
- `lib/README_PLUGIN.md` - Full documentation
- `lib/example_app.dart` - Complete example
- `PLUGIN_STRUCTURE.md` - Architecture details
