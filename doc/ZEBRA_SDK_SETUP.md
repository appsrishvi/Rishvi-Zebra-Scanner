# Zebra DataWedge Barcode Scanner - Simple Implementation

## Overview
This Flutter project implements a simple barcode scanner using Zebra DataWedge API. The implementation follows your exact specifications with the companion object constants and getApiData method pattern.

## Implementation Details

### Android MainActivity Features
- ✅ **Exact DataWedge Constants**: Uses your provided companion object constants
- ✅ **sendDataWedgeIntentWithExtra**: Your exact method implementation
- ✅ **startSoftScanTrigger**: With request code parameter
- ✅ **onActivityResult**: Handles activity results for barcode scanning
- ✅ **getApiData**: Processes barcode data with isFromBarcodeScan flag

### Flutter Integration
- ✅ **Simple Service**: Basic ZebraScannerService with minimal methods
- ✅ **Clean UI**: Focused on barcode scanning functionality only
- ✅ **Real-time Results**: Instant barcode display and history
- ✅ **No Extra Libraries**: Uses only built-in Flutter and DataWedge

## Key Methods Implemented

### Android (MainActivity.kt)
```kotlin
companion object {
    const val ACTION_RESULT_NOTIFICATION = "com.symbol.datawedge.api.NOTIFICATION_ACTION"
    const val ACTION_RESULT = "com.symbol.datawedge.api.RESULT_ACTION"
    const val EXTRA_KEY_APPLICATION_NAME = "com.symbol.datawedge.api.APPLICATION_NAME"
    const val EXTRA_KEY_NOTIFICATION_TYPE = "com.symbol.datawedge.api.NOTIFICATION_TYPE"
    const val EXTRA_KEY_VALUE_SCANNER_STATUS = "SCANNER_STATUS"
    const val EXTRA_UNREGISTER_NOTIFICATION = "com.symbol.datawedge.api.UNREGISTER_FOR_NOTIFICATION"
    const val ACTION_DATAWEDGE = "com.symbol.datawedge.api.ACTION"
    const val EXTRA_SOFT_SCAN_TRIGGER = "com.symbol.datawedge.api.SOFT_SCAN_TRIGGER"
}

private fun sendDataWedgeIntentWithExtra(action: String, extraKey: String, extraValue: String)
private fun startSoftScanTrigger(requestCode: Int)
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?)
private fun getApiData(barcodeData: String, isFromBarcodeScan: Boolean)
```

### Flutter (ZebraScannerService)
```dart
static Future<String> initializeScanner()
static Future<String> startScanning()
static Future<String> stopScanning()
static void initialize({Function(String)? onScanResult})
```

## How It Works

1. **Initialize**: Creates DataWedge profile and registers broadcast receiver
2. **Start Scanning**: Sends soft scan trigger with request code
3. **Receive Data**: BroadcastReceiver captures scan results
4. **Process Data**: getApiData method handles barcode with isFromBarcodeScan flag
5. **Display Result**: Flutter UI updates with scanned barcode

## Usage Instructions

### Build and Run
```bash
cd zebra_demoproject
flutter run
```

### On Zebra Device
1. **Initialize**: Tap "Initialize" button to set up DataWedge
2. **Start Scanning**: Tap "Start Scan" to begin scanning
3. **Scan Barcodes**: Point at barcode - result appears instantly
4. **View History**: All scanned barcodes are stored in history list
5. **Stop Scanning**: Tap "Stop Scan" when finished

## Features
- ✅ **Real-time Scanning**: Instant barcode capture and display
- ✅ **Scan History**: Chronological list of all scanned barcodes
- ✅ **Copy Function**: Copy barcodes to clipboard
- ✅ **Clean Interface**: Simple, focused UI
- ✅ **Status Updates**: Clear status messages for all operations

## Files Structure
```
zebra_demoproject/
├── android/app/src/main/kotlin/.../MainActivity.kt    # DataWedge integration
├── lib/zebra_scanner_service.dart                     # Flutter service
├── lib/main.dart                                      # Simple UI
└── android/app/src/main/AndroidManifest.xml          # Permissions
```

## No External Dependencies
- ✅ **No AAR files needed** - Uses built-in DataWedge
- ✅ **No third-party libraries** - Pure Flutter + DataWedge
- ✅ **No complex setup** - Just build and run
- ✅ **Production ready** - Follows Zebra best practices

This implementation provides exactly what you requested: a simple barcode scanner using your exact DataWedge implementation pattern with the companion object constants and getApiData method.