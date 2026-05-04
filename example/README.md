# Zebra Scanner Plugin - Example App

This example app demonstrates various real-world use cases for the Zebra Scanner Plugin.

## 🚀 Quick Start

```bash
cd example
flutter pub get
flutter run
```

## 📱 What's Included

Four complete, working examples demonstrating different use cases:

### 1. Basic Scanner
Simple barcode scanning with real-time display.

**Features:**
- Initialize scanner
- Start/stop scanning
- Display scanned barcode
- Show scanner status

**Use Case:** Quick barcode lookup or verification

### 2. Inventory Scanner
Scan and track inventory items with quantities.

**Features:**
- Scan multiple items
- Track quantities
- Add/remove items
- Clear inventory
- Real-time count display

**Use Case:** Stock taking, warehouse management

### 3. Batch Scanner
Continuous scanning mode for collecting multiple barcodes.

**Features:**
- Batch mode toggle
- Continuous scanning
- Scan history with timestamps
- Export batch data
- Clear batch

**Use Case:** Bulk data collection, shipping verification

### 4. Product Lookup
Scan barcodes to lookup product information.

**Features:**
- Scan barcode
- Lookup product details
- Display product info (name, price, stock)
- Handle not found cases
- Mock product database

**Use Case:** Retail POS, product information lookup

## 🚀 Running the Examples

### Prerequisites
- Zebra device with DataWedge
- Flutter SDK installed
- USB debugging enabled

### Run the App

```bash
cd example
flutter run
```

### On Zebra Device

1. Connect your Zebra device via USB
2. Enable USB debugging
3. Run `flutter run`
4. Select an example from the home screen
5. Start scanning!

## 📖 Code Examples

### Basic Scanner

```dart
import 'package:zebra_demoproject/zebra_scanner_plugin.dart';

// Initialize
await ZebraScanner.initialize();

// Listen to scans
ZebraScanner.scanResultStream.listen((result) {
  print('Scanned: ${result.data}');
});

// Start scanning
await ZebraScanner.startScan();
```

### Inventory Tracking

```dart
final Map<String, int> inventory = {};

ZebraScanner.scanResultStream.listen((result) {
  setState(() {
    inventory[result.data] = (inventory[result.data] ?? 0) + 1;
  });
});
```

### Batch Mode

```dart
final List<ScanResult> scans = [];
bool isBatchMode = false;

void toggleBatchMode() {
  isBatchMode = !isBatchMode;
  if (isBatchMode) {
    ZebraScanner.startScan();
  } else {
    ZebraScanner.stopScan();
  }
}

ZebraScanner.scanResultStream.listen((result) {
  scans.add(result);
});
```

### Product Lookup

```dart
ZebraScanner.scanResultStream.listen((result) async {
  final product = await lookupProduct(result.data);
  if (product != null) {
    showProductDetails(product);
  } else {
    showNotFound(result.data);
  }
});
```

## 🎯 Key Features Demonstrated

### Scanner Control
- Initialize scanner
- Start/stop scanning
- Handle scanner status

### Data Handling
- Single scan mode
- Continuous scanning
- Batch collection
- Data export

### UI Patterns
- Real-time updates
- Status indicators
- Error handling
- User feedback

### Business Logic
- Inventory tracking
- Quantity management
- Product lookup
- Data validation

## 📁 Project Structure

```
example/
├── lib/
│   └── main.dart              # All examples in one file
├── pubspec.yaml               # Dependencies
└── README.md                  # This file
```

## 🔧 Customization

### Add Your Own Example

```dart
class MyCustomExample extends StatefulWidget {
  @override
  State<MyCustomExample> createState() => _MyCustomExampleState();
}

class _MyCustomExampleState extends State<MyCustomExample> {
  @override
  void initState() {
    super.initState();
    ZebraScanner.initialize();
    ZebraScanner.scanResultStream.listen((result) {
      // Your custom logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    // Your custom UI here
  }

  @override
  void dispose() {
    ZebraScanner.dispose();
    super.dispose();
  }
}
```

### Modify Product Database

In `ProductLookupExample`, update the `_products` map:

```dart
final Map<String, Map<String, dynamic>> _products = {
  'YOUR_BARCODE': {
    'name': 'Your Product',
    'price': 99.99,
    'stock': 100,
    'category': 'Your Category',
  },
};
```

## 🐛 Troubleshooting

### Scanner not working?
1. Ensure DataWedge is installed
2. Check camera permissions
3. Verify USB debugging is enabled
4. Check logcat: `adb logcat | grep Zebra`

### No scan results?
1. Initialize scanner first
2. Check stream subscription
3. Verify DataWedge profile
4. Test with hardware trigger

### App crashes?
1. Check Flutter version compatibility
2. Verify plugin path in pubspec.yaml
3. Run `flutter clean && flutter pub get`
4. Check Android permissions

## 📚 Learn More

- **Plugin Documentation**: See `../README.md`
- **API Reference**: See `../QUICK_REFERENCE.md`
- **Usage Guide**: See `../PLUGIN_USAGE_GUIDE.md`

## 💡 Tips

1. **Always initialize** before scanning
2. **Dispose properly** to avoid memory leaks
3. **Handle errors** with try-catch blocks
4. **Test on device** - emulator won't work
5. **Check status** before operations

## 🎨 UI Customization

All examples use Material Design 3. Customize colors:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
  useMaterial3: true,
)
```

## 📊 Performance Tips

1. **Dispose streams** when not needed
2. **Debounce rapid scans** if needed
3. **Limit history size** in batch mode
4. **Use efficient data structures**

## 🤝 Contributing

Have a cool example? Feel free to add it!

1. Create your example widget
2. Add it to the home page list
3. Test on Zebra device
4. Submit a pull request

## 📄 License

MIT License - Same as the plugin

---

**Ready to explore? Run `flutter run` and try the examples!** 🎉
