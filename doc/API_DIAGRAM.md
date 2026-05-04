# Zebra Scanner Plugin - API Diagram

## Plugin API Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      YOUR FLUTTER APP                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ import 'zebra_scanner_plugin.dart'
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    ZebraScanner Class                       │
│                                                             │
│  Methods:                                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ • initialize() → Future<bool>                      │    │
│  │ • startScan() → Future<bool>                       │    │
│  │ • stopScan() → Future<bool>                        │    │
│  │ • dispose() → void                                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  Streams:                                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ • scanResultStream → Stream<ScanResult>            │    │
│  │ • statusStream → Stream<ScannerStatus>             │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  Properties:                                                │
│  ┌────────────────────────────────────────────────────┐    │
│  │ • currentStatus → ScannerStatus                    │    │
│  │ • isInitialized → bool                             │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ MethodChannel
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  MainActivity (Android)                     │
│                                                             │
│  Methods:                                                   │
│  • initializeScanner()                                      │
│  • startScanning()                                          │
│  • stopScanning()                                           │
│                                                             │
│  Callbacks:                                                 │
│  • onScanResult(Map)                                        │
│  • onStatusChange(String)                                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ DataWedge API
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Zebra Scanner Device                     │
└─────────────────────────────────────────────────────────────┘
```

## Data Models

```
┌─────────────────────────────────────────────────────────────┐
│                       ScanResult                            │
├─────────────────────────────────────────────────────────────┤
│  • data: String          (barcode data)                     │
│  • type: String?         (barcode type: QR, EAN-13, etc)    │
│  • timestamp: DateTime   (when scanned)                     │
│  • source: String?       (scan source)                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     ScannerStatus                           │
├─────────────────────────────────────────────────────────────┤
│  • uninitialized    (not set up yet)                        │
│  • ready            (ready to scan)                         │
│  • scanning         (actively scanning)                     │
│  • error            (error occurred)                        │
│  • disabled         (scanner disabled)                      │
└─────────────────────────────────────────────────────────────┘
```

## Typical Usage Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. App Starts                                               │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Initialize Scanner                                       │
│    await ZebraScanner.initialize()                          │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Set Up Listeners                                         │
│    ZebraScanner.scanResultStream.listen(...)                │
│    ZebraScanner.statusStream.listen(...)                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. User Clicks "Scan"                                       │
│    await ZebraScanner.startScan()                           │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Status Changes to "scanning"                             │
│    statusStream emits: ScannerStatus.scanning               │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. User Scans Barcode                                       │
│    (Physical scanner reads barcode)                         │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. Result Received                                          │
│    scanResultStream emits: ScanResult(data: "123456")       │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. Status Changes to "ready"                                │
│    statusStream emits: ScannerStatus.ready                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. App Closes                                               │
│    ZebraScanner.dispose()                                   │
└─────────────────────────────────────────────────────────────┘
```

## Stream Architecture

```
                    ┌──────────────────────┐
                    │   ZebraScanner       │
                    └──────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
    ┌──────────────────────┐  ┌──────────────────────┐
    │ scanResultStream     │  │   statusStream       │
    │ StreamController     │  │   StreamController   │
    └──────────────────────┘  └──────────────────────┘
                │                         │
                │                         │
    ┌───────────▼───────────┐ ┌──────────▼───────────┐
    │  Your App Listener    │ │  Your App Listener   │
    │  .listen((result) {   │ │  .listen((status) {  │
    │    // Handle scan     │ │    // Handle status  │
    │  })                   │ │  })                  │
    └───────────────────────┘ └──────────────────────┘
```

## Error Handling Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Method Call (e.g., startScan())                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  Try Block    │
                    └───────┬───────┘
                            │
                ┌───────────┴───────────┐
                │                       │
                ▼                       ▼
        ┌──────────────┐        ┌──────────────┐
        │   Success    │        │    Error     │
        │   Return     │        │   Catch      │
        │   true       │        │   Exception  │
        └──────────────┘        └──────┬───────┘
                                       │
                                       ▼
                            ┌──────────────────┐
                            │ Update Status    │
                            │ to "error"       │
                            └──────┬───────────┘
                                   │
                                   ▼
                            ┌──────────────────┐
                            │ Throw Exception  │
                            │ with message     │
                            └──────────────────┘
```

## State Transitions

```
    ┌──────────────────┐
    │  uninitialized   │
    └────────┬─────────┘
             │ initialize()
             ▼
    ┌──────────────────┐
    │      ready       │◄─────────┐
    └────────┬─────────┘          │
             │ startScan()        │
             ▼                    │
    ┌──────────────────┐          │
    │    scanning      │          │
    └────────┬─────────┘          │
             │ scan complete      │
             │ or stopScan()      │
             └────────────────────┘

    Any state can transition to:
    ┌──────────────────┐
    │      error       │
    └──────────────────┘
```

## Complete Example with Annotations

```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

class MyScanner extends StatefulWidget {
  @override
  State<MyScanner> createState() => _MyScannerState();
}

class _MyScannerState extends State<MyScanner> {
  String lastBarcode = '';
  
  @override
  void initState() {
    super.initState();
    
    // Step 1: Initialize the scanner
    ZebraScanner.initialize();
    
    // Step 2: Listen to scan results
    ZebraScanner.scanResultStream.listen((ScanResult result) {
      // ← Stream emits ScanResult objects
      setState(() {
        lastBarcode = result.data;  // ← Access barcode data
      });
    });
    
    // Step 3: Listen to status changes
    ZebraScanner.statusStream.listen((ScannerStatus status) {
      // ← Stream emits ScannerStatus enum
      print('Status: $status');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Last: $lastBarcode'),
            ElevatedButton(
              // Step 4: Start scanning
              onPressed: () => ZebraScanner.startScan(),
              child: Text('Scan'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    // Step 5: Clean up
    ZebraScanner.dispose();
    super.dispose();
  }
}
```

## Summary

This plugin provides a clean, stream-based API for Zebra scanner integration with:
- Simple initialization
- Reactive streams for results and status
- Type-safe models
- Comprehensive error handling
- Easy integration
