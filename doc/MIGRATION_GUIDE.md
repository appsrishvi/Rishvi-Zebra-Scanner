# Migration Guide: Old Service → New Plugin

## Overview

This guide helps you migrate from the old `ZebraScannerService` to the new `ZebraScanner` plugin.

## Key Differences

| Feature | Old (Service) | New (Plugin) |
|---------|--------------|--------------|
| API Style | Callback-based | Stream-based |
| Initialization | Manual callback setup | Automatic stream setup |
| Results | Callback function | Stream subscription |
| Status | Manual tracking | Automatic via stream |
| Type Safety | Basic | Full with models |
| State Management | Manual | Automatic |

## Side-by-Side Comparison

### Old Way (ZebraScannerService)

```dart
import 'zebra_scanner_service.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _lastBarcode = '';
  
  @override
  void initState() {
    super.initState();
    // Initialize with callback
    ZebraScannerService.initialize(
      onScanResult: _handleScanResult
    );
  }
  
  void _handleScanResult(String barcodeData) {
    setState(() {
      _lastBarcode = barcodeData;
    });
  }
  
  Future<void> _startScan() async {
    final result = await ZebraScannerService.startScanning();
    print(result);
  }
  
  @override
  void dispose() {
    ZebraScannerService.dispose();
    super.dispose();
  }
}
```

### New Way (ZebraScanner Plugin)

```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String _lastBarcode = '';
  
  @override
  void initState() {
    super.initState();
    // Initialize
    ZebraScanner.initialize();
    
    // Listen to stream
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _lastBarcode = result.data;
      });
    });
  }
  
  Future<void> _startScan() async {
    await ZebraScanner.startScan();
  }
  
  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}
```

## Migration Steps

### Step 1: Update Import

**Before:**
```dart
import 'zebra_scanner_service.dart';
```

**After:**
```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';
```

### Step 2: Update Initialization

**Before:**
```dart
ZebraScannerService.initialize(
  onScanResult: (String data) {
    // Handle result
  }
);
```

**After:**
```dart
await ZebraScanner.initialize();

ZebraScanner.scanResultStream.listen((ScanResult result) {
  // Handle result
  print(result.data);
});
```

### Step 3: Update Method Calls

**Before:**
```dart
await ZebraScannerService.initializeScanner();
await ZebraScannerService.startScanning();
await ZebraScannerService.stopScanning();
```

**After:**
```dart
await ZebraScanner.initialize();
await ZebraScanner.startScan();
await ZebraScanner.stopScan();
```

### Step 4: Add Status Monitoring (New Feature)

**New capability:**
```dart
ZebraScanner.statusStream.listen((status) {
  switch (status) {
    case ScannerStatus.ready:
      print('Ready to scan');
      break;
    case ScannerStatus.scanning:
      print('Scanning...');
      break;
    case ScannerStatus.error:
      print('Error occurred');
      break;
    default:
      break;
  }
});
```

### Step 5: Use Rich Result Data (New Feature)

**Before:**
```dart
void _handleScanResult(String barcodeData) {
  print(barcodeData);  // Just the string
}
```

**After:**
```dart
ZebraScanner.scanResultStream.listen((result) {
  print(result.data);       // Barcode data
  print(result.type);       // Barcode type
  print(result.timestamp);  // When scanned
  print(result.source);     // Scan source
});
```

## Complete Migration Example

### Before (Old Service)

```dart
import 'package:flutter/material.dart';
import 'zebra_scanner_service.dart';

class ScannerPage extends StatefulWidget {
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _statusMessage = 'Ready';
  String _lastBarcode = '';
  bool _isScanning = false;
  
  @override
  void initState() {
    super.initState();
    ZebraScannerService.initialize(
      onScanResult: _handleScanResult
    );
  }
  
  void _handleScanResult(String barcodeData) {
    setState(() {
      _lastBarcode = barcodeData;
      _statusMessage = 'Scanned: $barcodeData';
      _isScanning = false;
    });
  }
  
  Future<void> _initialize() async {
    try {
      final result = await ZebraScannerService.initializeScanner();
      setState(() => _statusMessage = result);
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  Future<void> _startScan() async {
    try {
      final result = await ZebraScannerService.startScanning();
      setState(() {
        _statusMessage = result;
        _isScanning = true;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  Future<void> _stopScan() async {
    try {
      final result = await ZebraScannerService.stopScanning();
      setState(() {
        _statusMessage = result;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(_statusMessage),
          Text(_lastBarcode),
          ElevatedButton(
            onPressed: _initialize,
            child: Text('Initialize'),
          ),
          ElevatedButton(
            onPressed: _isScanning ? null : _startScan,
            child: Text('Start'),
          ),
          ElevatedButton(
            onPressed: _isScanning ? _stopScan : null,
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    ZebraScannerService.dispose();
    super.dispose();
  }
}
```

### After (New Plugin)

```dart
import 'package:flutter/material.dart';
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

class ScannerPage extends StatefulWidget {
  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _statusMessage = 'Ready';
  String _lastBarcode = '';
  ScannerStatus _status = ScannerStatus.uninitialized;
  
  @override
  void initState() {
    super.initState();
    _setupScanner();
  }
  
  void _setupScanner() {
    // Initialize
    ZebraScanner.initialize();
    
    // Listen to scan results
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _lastBarcode = result.data;
        _statusMessage = 'Scanned: ${result.data}';
      });
    });
    
    // Listen to status changes
    ZebraScanner.statusStream.listen((status) {
      setState(() {
        _status = status;
        _statusMessage = _getStatusMessage(status);
      });
    });
  }
  
  String _getStatusMessage(ScannerStatus status) {
    switch (status) {
      case ScannerStatus.ready:
        return 'Ready to scan';
      case ScannerStatus.scanning:
        return 'Scanning...';
      case ScannerStatus.error:
        return 'Error occurred';
      default:
        return 'Not initialized';
    }
  }
  
  Future<void> _initialize() async {
    try {
      await ZebraScanner.initialize();
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  Future<void> _startScan() async {
    try {
      await ZebraScanner.startScan();
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  Future<void> _stopScan() async {
    try {
      await ZebraScanner.stopScan();
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isScanning = _status == ScannerStatus.scanning;
    
    return Scaffold(
      body: Column(
        children: [
          Text(_statusMessage),
          Text(_lastBarcode),
          ElevatedButton(
            onPressed: _initialize,
            child: Text('Initialize'),
          ),
          ElevatedButton(
            onPressed: isScanning ? null : _startScan,
            child: Text('Start'),
          ),
          ElevatedButton(
            onPressed: isScanning ? _stopScan : null,
            child: Text('Stop'),
          ),
        ],
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

## Benefits of Migration

### 1. Cleaner Code
- Stream-based API is more Flutter-idiomatic
- Less boilerplate code
- Better separation of concerns

### 2. Better Type Safety
- `ScanResult` model instead of plain string
- `ScannerStatus` enum for status tracking
- Compile-time type checking

### 3. More Features
- Automatic status tracking
- Timestamp on scans
- Barcode type information
- Source tracking

### 4. Easier Testing
- Streams are easier to test
- Mock-friendly architecture
- Better state management

### 5. Better Developer Experience
- Comprehensive documentation
- Complete example app
- Quick reference guides

## Backward Compatibility

The old `ZebraScannerService` is still available if you need it. Both can coexist in your project during migration.

## Quick Reference

| Old Method | New Method |
|------------|------------|
| `ZebraScannerService.initialize(onScanResult: ...)` | `ZebraScanner.initialize()` + stream |
| `ZebraScannerService.initializeScanner()` | `ZebraScanner.initialize()` |
| `ZebraScannerService.startScanning()` | `ZebraScanner.startScan()` |
| `ZebraScannerService.stopScanning()` | `ZebraScanner.stopScan()` |
| `ZebraScannerService.dispose()` | `ZebraScanner.dispose()` |
| Callback: `onScanResult(String)` | Stream: `scanResultStream.listen((result) {})` |
| Manual status tracking | Stream: `statusStream.listen((status) {})` |

## Need Help?

- See `QUICK_REFERENCE.md` for API reference
- See `PLUGIN_USAGE_GUIDE.md` for detailed guide
- See `lib/example_app.dart` for complete example
- See `API_DIAGRAM.md` for visual architecture

## Recommendation

Migrate to the new plugin for:
- Better code organization
- More features
- Easier maintenance
- Modern Flutter patterns
- Better documentation
