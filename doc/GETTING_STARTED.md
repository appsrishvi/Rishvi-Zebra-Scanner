# Getting Started with Zebra Scanner Plugin

## 🚀 Quick Start (3 Steps)

### 1. Import the Plugin

```dart
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';
```

### 2. Initialize and Listen

```dart
await ZebraScanner.initialize();

ZebraScanner.scanResultStream.listen((result) {
  print('Scanned: ${result.data}');
});
```

### 3. Start Scanning

```dart
await ZebraScanner.startScan();
```

That's it! You're ready to scan barcodes.

## 📱 Run the Example App

```bash
flutter run
```

The example app includes:
- ✅ Initialize button
- ✅ Start/Stop scan controls
- ✅ Real-time status display
- ✅ Scan history with timestamps
- ✅ Visual feedback

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **QUICK_REFERENCE.md** | Quick API reference card |
| **PLUGIN_USAGE_GUIDE.md** | Step-by-step usage guide |
| **API_DIAGRAM.md** | Visual architecture diagrams |
| **PLUGIN_STRUCTURE.md** | Plugin architecture details |
| **MIGRATION_GUIDE.md** | Migrate from old service |
| **IMPLEMENTATION_SUMMARY.md** | Complete implementation overview |
| **lib/README_PLUGIN.md** | Full plugin documentation |

## 🎯 Core API

### Initialize
```dart
await ZebraScanner.initialize();
```

### Listen to Scans
```dart
ZebraScanner.scanResultStream.listen((ScanResult result) {
  print(result.data);      // Barcode data
  print(result.type);      // Barcode type
  print(result.timestamp); // When scanned
});
```

### Listen to Status
```dart
ZebraScanner.statusStream.listen((ScannerStatus status) {
  // Handle status changes
});
```

### Control Scanning
```dart
await ZebraScanner.startScan();  // Start
await ZebraScanner.stopScan();   // Stop
```

### Clean Up
```dart
ZebraScanner.dispose();
```

## 📦 What's Included

### Plugin Files
- `lib/zebra_scanner_plugin.dart` - Main export
- `lib/src/zebra_scanner.dart` - Core scanner class
- `lib/src/models/scan_result.dart` - Result model
- `lib/src/models/scanner_status.dart` - Status enum

### Example & Docs
- `lib/example_app.dart` - Complete example
- `lib/main.dart` - App entry point
- Multiple documentation files

### Android Implementation
- `android/.../MainActivity.kt` - Native implementation
- DataWedge integration
- Broadcast receiver setup

## ✨ Features

- ✅ Initialize scanner
- ✅ Start/stop scanning
- ✅ Stream-based results
- ✅ Status monitoring
- ✅ Type-safe models
- ✅ Error handling
- ✅ Clean architecture
- ✅ Full documentation
- ✅ Working example
- ✅ Unit tests

## 🔧 Requirements

- Flutter SDK: >=3.0.0
- Android: API 23+ (Android 6.0+)
- Zebra device with DataWedge

## 📱 Testing

### On Zebra Device

1. Connect your Zebra device
2. Run: `flutter run`
3. Click "Initialize"
4. Click "Start Scan"
5. Scan a barcode
6. See result appear

### Run Tests

```bash
flutter test
```

## 🎨 Example Code

### Minimal Example

```dart
import 'package:flutter/material.dart';
import 'package:zebra_scanner_plugin/zebra_scanner_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcode = 'No scan yet';

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
        appBar: AppBar(title: Text('Scanner')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(barcode, style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
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

## 🐛 Troubleshooting

### Scanner not working?
1. Ensure DataWedge is installed
2. Check camera permissions
3. Verify it's a Zebra device
4. Check logcat: `adb logcat | grep Zebra`

### No scan results?
1. Call `initialize()` first
2. Listen to `scanResultStream`
3. Check DataWedge profile
4. Verify device settings

## 📖 Learn More

### Quick Start
- Read `QUICK_REFERENCE.md` for API reference
- Check `lib/example_app.dart` for complete example

### Deep Dive
- Read `PLUGIN_USAGE_GUIDE.md` for detailed guide
- Check `API_DIAGRAM.md` for architecture
- Read `PLUGIN_STRUCTURE.md` for internals

### Migration
- Read `MIGRATION_GUIDE.md` if upgrading from old service

## 🎯 Next Steps

1. ✅ Run the example app
2. ✅ Read the quick reference
3. ✅ Integrate into your app
4. ✅ Customize as needed
5. ✅ Test on your Zebra device

## 💡 Tips

- Always initialize before scanning
- Use streams for real-time updates
- Dispose when done
- Handle errors with try-catch
- Check status before operations

## 🤝 Support

Need help?
1. Check documentation files
2. Review example app
3. Check Android logcat
4. Verify DataWedge setup

## 📄 License

MIT License

---

**Ready to scan? Run `flutter run` and start scanning!** 🎉
