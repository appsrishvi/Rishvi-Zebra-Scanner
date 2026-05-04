# Zebra Scanner Plugin - Examples Guide

This guide explains each example in detail and shows you how to use them.

## 📱 Example 1: Basic Scanner

### What It Does
Simple barcode scanning with real-time display of the scanned barcode and scanner status.

### Key Features
- Single scan mode
- Real-time status display
- Simple, clean UI
- Easy to understand code

### Code Walkthrough

```dart
class _BasicScannerExampleState extends State<BasicScannerExample> {
  String _barcode = 'No scan yet';
  ScannerStatus _status = ScannerStatus.uninitialized;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    // Step 1: Initialize the scanner
    await ZebraScanner.initialize();
    
    // Step 2: Listen to scan results
    ZebraScanner.scanResultStream.listen((result) {
      setState(() => _barcode = result.data);
    });
    
    // Step 3: Listen to status changes
    ZebraScanner.statusStream.listen((status) {
      setState(() => _status = status);
    });
  }
}
```

### Use Cases
- Quick barcode verification
- Simple product lookup
- Testing scanner functionality
- Learning the basics

### Try It
1. Open the app
2. Tap "Basic Scanner"
3. Tap "Start Scan"
4. Point scanner at a barcode
5. See the result instantly

---

## 📦 Example 2: Inventory Scanner

### What It Does
Tracks multiple items with quantities, perfect for inventory management.

### Key Features
- Scan multiple items
- Automatic quantity tracking
- Add/remove items
- Total count display
- Clear all functionality

### Code Walkthrough

```dart
class _InventoryScannerExampleState extends State<InventoryScannerExample> {
  final Map<String, int> _inventory = {};

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();
    
    // Increment quantity on each scan
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _inventory[result.data] = (_inventory[result.data] ?? 0) + 1;
      });
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added: ${result.data}')),
      );
    });
  }
}
```

### Data Structure

```dart
// Inventory map: barcode -> quantity
{
  '123456789': 5,   // 5 units of product 123456789
  '987654321': 3,   // 3 units of product 987654321
}
```

### Use Cases
- Stock taking
- Warehouse inventory
- Retail stock count
- Asset tracking

### Try It
1. Open "Inventory Scanner"
2. Tap the FAB to start scanning
3. Scan multiple items (same or different)
4. Watch quantities update
5. Tap minus to reduce quantity
6. Tap trash to clear all

---

## 📋 Example 3: Batch Scanner

### What It Does
Continuous scanning mode that collects multiple barcodes with timestamps.

### Key Features
- Batch mode toggle
- Continuous scanning
- Timestamp tracking
- Export functionality
- Scan history

### Code Walkthrough

```dart
class _BatchScannerExampleState extends State<BatchScannerExample> {
  final List<ScanResult> _scans = [];
  bool _isBatchMode = false;

  void _toggleBatchMode() {
    setState(() {
      _isBatchMode = !_isBatchMode;
      if (_isBatchMode) {
        ZebraScanner.startScan();  // Auto-start in batch mode
      } else {
        ZebraScanner.stopScan();   // Auto-stop when disabled
      }
    });
  }

  Future<void> _initScanner() async {
    await ZebraScanner.initialize();
    
    // Collect all scans
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _scans.insert(0, result);  // Add to beginning
      });
    });
  }
}
```

### Batch Mode Flow

```
1. User enables batch mode
   ↓
2. Scanner starts automatically
   ↓
3. User scans multiple items
   ↓
4. Each scan is added to list
   ↓
5. User disables batch mode
   ↓
6. Scanner stops automatically
   ↓
7. User exports data
```

### Export Format

```
Barcode 1
Barcode 2
Barcode 3
...
```

### Use Cases
- Bulk data collection
- Shipping verification
- Package tracking
- Order fulfillment

### Try It
1. Open "Batch Scanner"
2. Toggle batch mode ON
3. Scan multiple items rapidly
4. Toggle batch mode OFF
5. Tap export to view data
6. Clear when done

---

## 🔍 Example 4: Product Lookup

### What It Does
Scans barcodes and displays detailed product information from a database.

### Key Features
- Product database lookup
- Detailed product info
- Not found handling
- Loading states
- Mock database

### Code Walkthrough

```dart
class _ProductLookupExampleState extends State<ProductLookupExample> {
  String? _scannedBarcode;
  Map<String, dynamic>? _productInfo;
  bool _isLoading = false;

  // Mock product database
  final Map<String, Map<String, dynamic>> _products = {
    '123456789': {
      'name': 'Product A',
      'price': 29.99,
      'stock': 150,
      'category': 'Electronics',
    },
  };

  Future<void> _lookupProduct(String barcode) async {
    setState(() {
      _scannedBarcode = barcode;
      _isLoading = true;
      _productInfo = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _productInfo = _products[barcode];
      _isLoading = false;
    });
  }
}
```

### Lookup Flow

```
1. User scans barcode
   ↓
2. Show loading indicator
   ↓
3. Query database (or API)
   ↓
4. Product found?
   ├─ Yes: Display product info
   └─ No: Show "not found" message
```

### Customizing the Database

Replace the mock database with real API calls:

```dart
Future<Map<String, dynamic>?> _lookupProduct(String barcode) async {
  try {
    final response = await http.get(
      Uri.parse('https://api.example.com/products/$barcode'),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
```

### Use Cases
- Retail POS systems
- Product information lookup
- Price checking
- Inventory verification

### Try It
1. Open "Product Lookup"
2. Tap "Scan Another"
3. Scan barcode "123456789" or "987654321"
4. See product details
5. Try an unknown barcode
6. See "not found" message

---

## 🎯 Common Patterns

### Pattern 1: Initialize Once

```dart
@override
void initState() {
  super.initState();
  ZebraScanner.initialize();  // Initialize once
  _setupListeners();          // Set up listeners
}
```

### Pattern 2: Stream Subscription

```dart
ZebraScanner.scanResultStream.listen((result) {
  // Handle scan result
  print(result.data);
  print(result.type);
  print(result.timestamp);
});
```

### Pattern 3: Status Monitoring

```dart
ZebraScanner.statusStream.listen((status) {
  switch (status) {
    case ScannerStatus.ready:
      // Enable scan button
      break;
    case ScannerStatus.scanning:
      // Show scanning indicator
      break;
    case ScannerStatus.error:
      // Show error message
      break;
  }
});
```

### Pattern 4: Cleanup

```dart
@override
void dispose() {
  ZebraScanner.dispose();  // Always dispose
  super.dispose();
}
```

---

## 💡 Tips & Best Practices

### 1. Always Initialize First
```dart
// ✅ Good
await ZebraScanner.initialize();
await ZebraScanner.startScan();

// ❌ Bad
await ZebraScanner.startScan();  // Will throw error
```

### 2. Handle Errors
```dart
try {
  await ZebraScanner.startScan();
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

### 3. Provide User Feedback
```dart
ZebraScanner.scanResultStream.listen((result) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Scanned: ${result.data}')),
  );
});
```

### 4. Check Status Before Actions
```dart
if (ZebraScanner.currentStatus == ScannerStatus.ready) {
  await ZebraScanner.startScan();
}
```

### 5. Dispose Properly
```dart
@override
void dispose() {
  ZebraScanner.dispose();  // Prevent memory leaks
  super.dispose();
}
```

---

## 🔧 Customization Ideas

### Add Sound Feedback
```dart
import 'package:audioplayers/audioplayers.dart';

ZebraScanner.scanResultStream.listen((result) {
  AudioPlayer().play(AssetSource('beep.mp3'));
});
```

### Add Vibration
```dart
import 'package:vibration/vibration.dart';

ZebraScanner.scanResultStream.listen((result) {
  Vibration.vibrate(duration: 100);
});
```

### Validate Barcodes
```dart
ZebraScanner.scanResultStream.listen((result) {
  if (result.data.length == 13) {
    // Valid EAN-13
    processBarcode(result.data);
  } else {
    showError('Invalid barcode format');
  }
});
```

### Debounce Rapid Scans
```dart
import 'dart:async';

Timer? _debounce;

ZebraScanner.scanResultStream.listen((result) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    processBarcode(result.data);
  });
});
```

---

## 🐛 Troubleshooting

### Example won't run?
```bash
cd example
flutter clean
flutter pub get
flutter run
```

### Scanner not working?
1. Check DataWedge is installed
2. Verify permissions in AndroidManifest.xml
3. Test with hardware trigger button
4. Check logcat: `adb logcat | grep Zebra`

### No scan results?
1. Ensure `initialize()` is called
2. Check stream subscription is active
3. Verify scanner status is not error
4. Test with a known good barcode

### App crashes?
1. Check Flutter version: `flutter --version`
2. Verify plugin path in pubspec.yaml
3. Run `flutter doctor`
4. Check Android build.gradle settings

---

## 📚 Next Steps

1. **Run all examples** to see different patterns
2. **Modify the code** to fit your needs
3. **Add your own example** following the patterns
4. **Integrate into your app** using these examples as reference

## 🤝 Contributing

Have a cool example idea? Add it to the app!

1. Create your example widget
2. Add it to the home page
3. Document it in this guide
4. Test on a Zebra device
5. Submit a PR

---

**Happy scanning!** 🎉
