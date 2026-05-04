# Zebra Scanner Plugin - Troubleshooting Guide

## Common Issues and Solutions

### Issue: MissingPluginException

**Error:**
```
MissingPluginException(No implementation found for method initializeScanner on channel zebra_barcode_scanner)
```

**Cause:** The Flutter plugin isn't properly connected to the Android native code.

**Solutions:**

#### For Main Demo App
The main app should work out of the box. If you see this error:

1. Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

2. Verify the plugin class exists:
```bash
ls android/src/main/kotlin/com/example/zebra_demoproject/ZebraScannerPlugin.kt
```

3. Check pubspec.yaml has plugin configuration:
```yaml
flutter:
  plugin:
    platforms:
      android:
        package: com.example.zebra_demoproject
        pluginClass: ZebraScannerPlugin
```

#### For Example Project
The example project has its own MainActivity with the full implementation:

1. Verify MainActivity exists:
```bash
ls example/android/app/src/main/kotlin/com/example/zebra_scanner_example/MainActivity.kt
```

2. Clean and rebuild:
```bash
cd example
flutter clean
flutter pub get
flutter run
```

3. If still failing, check the parent plugin is properly configured (see above).

### Issue: "Cannot add new events after calling close"

**Error:**
```
Bad state: Cannot add new events after calling close
```

**Cause:** The stream controller was closed by calling `dispose()` and then the app tried to use the scanner again.

**Solutions:**

1. **Don't call dispose() unless you're done with the scanner:**
```dart
// ❌ Bad - calling dispose too early
@override
void dispose() {
  ZebraScanner.dispose();  // This closes the streams
  super.dispose();
}

// Then trying to use scanner again will fail

// ✅ Good - only dispose when truly done
@override
void dispose() {
  // Only call if this is the last widget using the scanner
  if (mounted) {
    ZebraScanner.stopScan();
  }
  super.dispose();
}
```

2. **For navigation between pages:**
```dart
// Don't dispose when navigating
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AnotherPage()),
);

// The scanner stays initialized and can be used in the new page
```

3. **If you need to reinitialize:**
```dart
// The plugin now handles recreation automatically
await ZebraScanner.initialize();  // Safe to call multiple times
```

4. **For multiple examples/pages:**
```dart
// Initialize once in main app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZebraScanner.initialize();
  runApp(MyApp());
}

// Then use in any page without reinitializing
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Just listen to streams, no need to initialize again
    ZebraScanner.scanResultStream.listen((result) {
      print(result.data);
    });
    return Scaffold(...);
  }
}
```

### Issue: Scanner Not Working

**Symptoms:**
- App runs but scanner doesn't respond
- No scan results received
- Hardware trigger doesn't work

**Solutions:**

1. **Check DataWedge is installed:**
   - DataWedge comes pre-installed on Zebra devices
   - Open DataWedge app to verify it's present

2. **Check permissions:**
   - Camera permission must be granted
   - Check in Settings > Apps > Your App > Permissions

3. **Verify device is a Zebra scanner:**
   - This plugin only works on Zebra devices with DataWedge
   - Won't work on regular Android devices or emulators

4. **Check logcat:**
```bash
adb logcat | grep Zebra
```

Look for:
- "DataWedge initialized successfully"
- "Scan result received"
- Any error messages

5. **Test hardware trigger:**
   - Try pressing the physical scan button
   - Should activate scanner even if soft trigger doesn't work

### Issue: No Scan Results

**Symptoms:**
- Scanner activates (laser/camera turns on)
- But no results appear in the app

**Solutions:**

1. **Check stream subscription:**
```dart
// Make sure you're listening to the stream
ZebraScanner.scanResultStream.listen((result) {
  print('Received: ${result.data}');
});
```

2. **Verify initialization:**
```dart
// Must initialize before scanning
await ZebraScanner.initialize();
```

3. **Check DataWedge profile:**
   - Open DataWedge app
   - Look for "ZebraFlutterProfile"
   - Verify it's enabled and associated with your app

4. **Test with known barcode:**
   - Use a test barcode (search "test barcode" online)
   - Try different barcode types (QR, EAN-13, etc.)

### Issue: App Crashes on Startup

**Symptoms:**
- App crashes immediately after launch
- Error in logcat about permissions or receivers

**Solutions:**

1. **Check AndroidManifest.xml permissions:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

2. **Verify Android version compatibility:**
   - Minimum SDK: API 23 (Android 6.0)
   - Target SDK: API 34 or higher

3. **Check for duplicate receivers:**
   - Only one BroadcastReceiver should be registered
   - Check MainActivity.kt for proper registration

4. **Clean build:**
```bash
flutter clean
cd android && ./gradlew clean
cd ..
flutter pub get
flutter run
```

### Issue: Build Errors

**Symptoms:**
- Gradle build fails
- Kotlin compilation errors
- Plugin not found errors
- NullPointerException during configuration

**Solutions:**

1. **Missing plugin build files:**

If you see "NullPointerException" or "Failed to notify project evaluation listener":

The plugin needs proper Android build configuration. Verify these files exist:

```bash
# Check plugin build files
ls android/build.gradle.kts
ls android/src/main/AndroidManifest.xml
ls android/src/main/kotlin/com/example/zebra_demoproject/ZebraScannerPlugin.kt
```

If missing, the plugin structure is incomplete. Run:
```bash
flutter clean
flutter pub get
```

2. **Update Gradle:**
   - Check `android/gradle/wrapper/gradle-wrapper.properties`
   - Should use Gradle 8.0 or higher

3. **Update Kotlin:**
   - Check `android/build.gradle.kts`
   - Should use Kotlin 1.9.0 or higher

4. **Sync Gradle:**
```bash
cd android
./gradlew clean
./gradlew build
cd ..
```

5. **Check Android Studio:**
   - Open `android/` folder in Android Studio
   - Let it sync and download dependencies
   - Fix any errors shown

### Issue: Example Project Won't Run

**Symptoms:**
- Main app works but example project doesn't
- MissingPluginException in example project

**Solution:**

The example project has its own MainActivity. Verify it exists:

```bash
ls example/android/app/src/main/kotlin/com/example/zebra_scanner_example/MainActivity.kt
```

If missing, copy from parent:
```bash
cp android/app/src/main/kotlin/com/example/zebra_demoproject/MainActivity.kt \
   example/android/app/src/main/kotlin/com/example/zebra_scanner_example/MainActivity.kt
```

Then update the package name in the copied file:
```kotlin
package com.example.zebra_scanner_example
```

### Issue: Permissions Denied

**Symptoms:**
- Permission dialog doesn't appear
- Scanner doesn't work after denying permissions

**Solutions:**

1. **Manually grant permissions:**
   - Settings > Apps > Your App > Permissions
   - Enable Camera permission

2. **Reinstall app:**
```bash
flutter clean
flutter run
```

3. **Check permission request code:**
   - Look in MainActivity.kt
   - Verify `checkAndRequestPermissions()` is called

### Issue: DataWedge Profile Not Created

**Symptoms:**
- Scanner doesn't respond
- No profile in DataWedge app

**Solutions:**

1. **Manually create profile:**
   - Open DataWedge app
   - Create new profile: "ZebraFlutterProfile"
   - Associate with your app package name
   - Enable Intent output
   - Set action: `com.symbol.datawedge.api.RESULT`

2. **Check app package name:**
   - Must match in DataWedge and AndroidManifest.xml
   - Main app: `com.example.zebra_demoproject`
   - Example: `com.example.zebra_scanner_example`

3. **Reset DataWedge:**
   - DataWedge > Menu > Settings > Restore
   - Restart app to recreate profile

## Debugging Tips

### Enable Verbose Logging

Add to MainActivity.kt:
```kotlin
private val TAG = "ZebraDataWedge"

// Add more Log.d() statements
Log.d(TAG, "Method called: ${call.method}")
Log.d(TAG, "Scan data: $scanData")
```

### Check Flutter Logs

```bash
flutter logs
```

### Check Android Logs

```bash
adb logcat | grep -E "flutter|Zebra|DataWedge"
```

### Test DataWedge Directly

1. Open DataWedge app
2. Enable "Demo Mode"
3. Scan a barcode
4. Verify DataWedge receives it

If DataWedge works but your app doesn't, the issue is in your app's integration.

## Platform-Specific Issues

### Android 13+ (API 33+)

**Issue:** Broadcast receiver not working

**Solution:** Use `RECEIVER_EXPORTED` flag:
```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
} else {
    registerReceiver(receiver, filter)
}
```

### Android 12+ (API 31+)

**Issue:** PendingIntent errors

**Solution:** Add mutability flag:
```kotlin
PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
```

### Android 11+ (API 30+)

**Issue:** Package visibility restrictions

**Solution:** Add to AndroidManifest.xml:
```xml
<queries>
    <package android:name="com.symbol.datawedge" />
</queries>
```

## Still Having Issues?

1. **Check documentation:**
   - README.md
   - PLUGIN_USAGE_GUIDE.md
   - example/EXAMPLES_GUIDE.md

2. **Review example code:**
   - lib/example_app.dart
   - example/lib/main.dart

3. **Check Android implementation:**
   - android/app/src/main/kotlin/.../MainActivity.kt

4. **Verify device:**
   - Must be a Zebra device
   - DataWedge must be installed
   - Scanner hardware must be functional

5. **Test with simple code:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await ZebraScanner.initialize();
    print('Scanner initialized');
    
    ZebraScanner.scanResultStream.listen((result) {
      print('Scanned: ${result.data}');
    });
    
    await ZebraScanner.startScan();
    print('Scanning started');
  } catch (e) {
    print('Error: $e');
  }
  
  runApp(MyApp());
}
```

## Quick Fixes Checklist

- [ ] Run `flutter clean && flutter pub get`
- [ ] Check camera permissions granted
- [ ] Verify running on Zebra device
- [ ] Check DataWedge is installed
- [ ] Verify MainActivity exists
- [ ] Check logcat for errors
- [ ] Test hardware trigger button
- [ ] Verify plugin configuration in pubspec.yaml
- [ ] Check Android SDK versions
- [ ] Rebuild from scratch

## Contact & Support

If none of these solutions work:

1. Check the error message carefully
2. Search logcat for the full stack trace
3. Review the documentation again
4. Try the example project
5. Compare your code with the examples

---

**Most issues are solved by:**
1. `flutter clean && flutter pub get && flutter run`
2. Granting camera permissions
3. Running on an actual Zebra device
4. Checking logcat for specific errors
