# Quick Start - Example App

Get the example app running in 3 steps!

## 1️⃣ Navigate to Example

```bash
cd example
```

## 2️⃣ Get Dependencies

```bash
flutter pub get
```

## 3️⃣ Run on Zebra Device

```bash
flutter run
```

That's it! The app will launch on your connected Zebra device.

## 📱 What You'll See

### Home Screen
Four example cards:
- **Basic Scanner** - Simple scanning
- **Inventory Scanner** - Track quantities
- **Batch Scanner** - Collect multiple scans
- **Product Lookup** - Database lookup

### Try Each Example
Tap any card to open that example and start scanning!

## 🎯 Quick Test

### Test Basic Scanner
1. Tap "Basic Scanner"
2. Tap "Start Scan"
3. Scan any barcode
4. See result appear

### Test Inventory
1. Tap "Inventory Scanner"
2. Tap the green FAB
3. Scan same barcode multiple times
4. Watch quantity increase

### Test Batch Mode
1. Tap "Batch Scanner"
2. Toggle batch mode ON
3. Scan multiple items
4. Toggle OFF and export

### Test Product Lookup
1. Tap "Product Lookup"
2. Scan barcode "123456789"
3. See product details
4. Try unknown barcode

## 🔧 Requirements

- Zebra device with DataWedge
- Flutter SDK installed
- USB debugging enabled
- Device connected via USB

## 🐛 Issues?

### Can't run?
```bash
flutter doctor
```

### Dependencies error?
```bash
flutter clean
flutter pub get
```

### Scanner not working?
- Check DataWedge is installed
- Enable camera permissions
- Test hardware trigger button

## 📚 Learn More

- **EXAMPLES_GUIDE.md** - Detailed guide for each example
- **README.md** - Full documentation
- **../QUICK_REFERENCE.md** - Plugin API reference

## 💡 Next Steps

1. ✅ Run the examples
2. ✅ Understand the code
3. ✅ Modify for your needs
4. ✅ Build your own app

---

**Ready? Run `flutter run` now!** 🚀
