# Zebra Scanner Plugin - Examples Overview

## 📦 What's Included

This project includes **TWO** complete applications demonstrating the Zebra Scanner Plugin:

### 1. Main Demo App (Root Directory)
**Location:** `lib/example_app.dart`

A comprehensive demo showing all plugin features in one app:
- Initialize scanner
- Start/Stop controls
- Real-time status display
- Scan history with timestamps
- Visual feedback
- Clean, modern UI

**Run it:**
```bash
flutter run
```

### 2. Example Project (example/ Directory)
**Location:** `example/`

Four separate examples showing different use cases:

#### Example 1: Basic Scanner
Simple barcode scanning with real-time display.
- Single scan mode
- Status monitoring
- Clean, minimal UI

#### Example 2: Inventory Scanner
Track inventory items with quantities.
- Multiple item tracking
- Quantity management
- Add/remove items
- Total count display

#### Example 3: Batch Scanner
Continuous scanning for bulk data collection.
- Batch mode toggle
- Continuous scanning
- Timestamp tracking
- Export functionality

#### Example 4: Product Lookup
Scan and lookup product information.
- Database lookup
- Product details display
- Not found handling
- Mock database included

**Run it:**
```bash
cd example
flutter run
```

## 🎯 Which One to Use?

### Use Main Demo App When:
- Learning the plugin basics
- Testing scanner functionality
- Quick prototyping
- Understanding core features

### Use Example Project When:
- Building specific use cases
- Learning different patterns
- Implementing business logic
- Customizing for your needs

## 📊 Comparison

| Feature | Main Demo | Example Project |
|---------|-----------|-----------------|
| Examples | 1 comprehensive | 4 specific use cases |
| Complexity | Medium | Simple to Medium |
| Use Cases | General demo | Specific scenarios |
| Code Style | All-in-one | Modular examples |
| Best For | Learning basics | Implementation patterns |

## 🚀 Quick Start

### Try Main Demo
```bash
# From project root
flutter run
```

### Try Examples
```bash
# From project root
cd example
flutter run
```

## 📁 Project Structure

```
zebra_demoproject/
├── lib/
│   ├── zebra_scanner_plugin.dart    # Plugin export
│   ├── example_app.dart             # Main demo app
│   ├── main.dart                    # Entry point
│   └── src/                         # Plugin source
│       ├── zebra_scanner.dart
│       └── models/
│
├── example/                         # Example project
│   ├── lib/
│   │   └── main.dart               # 4 examples
│   ├── pubspec.yaml
│   ├── README.md
│   ├── QUICK_START.md
│   └── EXAMPLES_GUIDE.md
│
├── android/                        # Android implementation
├── README.md                       # Main documentation
├── QUICK_REFERENCE.md             # API reference
├── PLUGIN_USAGE_GUIDE.md          # Usage guide
└── [other docs]
```

## 📚 Documentation Map

### Getting Started
1. **README.md** - Start here
2. **GETTING_STARTED.md** - Quick start guide
3. **QUICK_REFERENCE.md** - API quick reference

### Main Demo
4. **lib/example_app.dart** - Main demo source code
5. **IMPLEMENTATION_SUMMARY.md** - Implementation details

### Example Project
6. **example/README.md** - Example project overview
7. **example/QUICK_START.md** - Run examples quickly
8. **example/EXAMPLES_GUIDE.md** - Detailed guide for each example

### Deep Dive
9. **PLUGIN_USAGE_GUIDE.md** - Comprehensive usage guide
10. **API_DIAGRAM.md** - Visual architecture
11. **PLUGIN_STRUCTURE.md** - Plugin internals
12. **MIGRATION_GUIDE.md** - Migration from old code

## 🎨 Example Use Cases

### Main Demo App
```dart
// All-in-one demo with:
- Scanner initialization
- Start/Stop controls
- Status monitoring
- Scan history
- Visual feedback
```

### Example 1: Basic Scanner
```dart
// Simple scanning
await ZebraScanner.initialize();
ZebraScanner.scanResultStream.listen((result) {
  print(result.data);
});
await ZebraScanner.startScan();
```

### Example 2: Inventory Scanner
```dart
// Track quantities
final Map<String, int> inventory = {};
ZebraScanner.scanResultStream.listen((result) {
  inventory[result.data] = (inventory[result.data] ?? 0) + 1;
});
```

### Example 3: Batch Scanner
```dart
// Collect multiple scans
final List<ScanResult> scans = [];
ZebraScanner.scanResultStream.listen((result) {
  scans.add(result);
});
```

### Example 4: Product Lookup
```dart
// Database lookup
ZebraScanner.scanResultStream.listen((result) async {
  final product = await lookupProduct(result.data);
  showProductDetails(product);
});
```

## 💡 Learning Path

### Beginner
1. Run main demo app
2. Read QUICK_REFERENCE.md
3. Try basic scanner example
4. Understand the code

### Intermediate
1. Try all 4 examples
2. Read EXAMPLES_GUIDE.md
3. Modify examples for your needs
4. Read PLUGIN_USAGE_GUIDE.md

### Advanced
1. Read PLUGIN_STRUCTURE.md
2. Study Android implementation
3. Customize for your use case
4. Build production app

## 🔧 Customization

### Modify Main Demo
Edit `lib/example_app.dart`:
```dart
// Change colors
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.yourColor),
)

// Add features
// Modify UI
// Add business logic
```

### Modify Examples
Edit `example/lib/main.dart`:
```dart
// Add your own example
class MyCustomExample extends StatefulWidget {
  // Your implementation
}

// Add to home page
_buildExampleCard(
  context,
  title: 'My Example',
  description: 'My custom use case',
  icon: Icons.my_icon,
  onTap: () => Navigator.push(...),
)
```

## 🐛 Troubleshooting

### Main Demo Issues
```bash
flutter clean
flutter pub get
flutter run
```

### Example Project Issues
```bash
cd example
flutter clean
flutter pub get
flutter run
```

### Scanner Not Working
1. Check DataWedge installed
2. Verify permissions
3. Test hardware trigger
4. Check logcat: `adb logcat | grep Zebra`

## 📊 Feature Matrix

| Feature | Main Demo | Basic | Inventory | Batch | Lookup |
|---------|-----------|-------|-----------|-------|--------|
| Initialize | ✅ | ✅ | ✅ | ✅ | ✅ |
| Start/Stop | ✅ | ✅ | ✅ | ✅ | ✅ |
| Status | ✅ | ✅ | ✅ | ✅ | ✅ |
| History | ✅ | ❌ | ❌ | ✅ | ❌ |
| Quantities | ❌ | ❌ | ✅ | ❌ | ❌ |
| Batch Mode | ❌ | ❌ | ❌ | ✅ | ❌ |
| Database | ❌ | ❌ | ❌ | ❌ | ✅ |
| Export | ❌ | ❌ | ❌ | ✅ | ❌ |

## 🎯 Next Steps

1. ✅ Run main demo app
2. ✅ Run example project
3. ✅ Try all examples
4. ✅ Read documentation
5. ✅ Customize for your needs
6. ✅ Build your app

## 📞 Support

### Documentation
- Main: README.md
- Examples: example/README.md
- API: QUICK_REFERENCE.md
- Guide: PLUGIN_USAGE_GUIDE.md

### Troubleshooting
- Check documentation
- Review example code
- Check logcat
- Verify DataWedge setup

## 📄 License

MIT License - Free to use and modify

---

**Ready to explore? Pick an app and start scanning!** 🎉

### Quick Commands

```bash
# Main demo
flutter run

# Example project
cd example && flutter run

# Clean build
flutter clean && flutter pub get && flutter run
```
