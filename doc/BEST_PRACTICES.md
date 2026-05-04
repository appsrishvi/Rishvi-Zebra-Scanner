# Zebra Scanner Plugin - Best Practices

## Initialization

### ✅ Do: Initialize Once
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ZebraScanner.initialize();
  runApp(MyApp());
}
```

### ❌ Don't: Initialize in Every Widget
```dart
// Bad - initializes multiple times
class MyWidget extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    ZebraScanner.initialize();  // Don't do this in every widget
  }
}
```

## Stream Subscriptions

### ✅ Do: Store and Cancel Subscriptions
```dart
class _MyPageState extends State<MyPage> {
  StreamSubscription<ScanResult>? _scanSubscription;
  
  @override
  void initState() {
    super.initState();
    _scanSubscription = ZebraScanner.scanResultStream.listen((result) {
      // Handle result
    });
  }
  
  @override
  void dispose() {
    _scanSubscription?.cancel();  // Cancel subscription
    super.dispose();
  }
}
```

### ❌ Don't: Leave Subscriptions Active
```dart
// Bad - memory leak
class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    ZebraScanner.scanResultStream.listen((result) {
      // This subscription never gets cancelled
    });
  }
  // Missing dispose - memory leak!
}
```

## Dispose

### ✅ Do: Only Dispose When Truly Done
```dart
// Only call dispose when app is closing
class MyApp extends StatefulWidget {
  @override
  void dispose() {
    ZebraScanner.dispose();  // OK - app is closing
    super.dispose();
  }
}
```

### ❌ Don't: Dispose on Every Page
```dart
// Bad - breaks scanner for other pages
class _MyPageState extends State<MyPage> {
  @override
  void dispose() {
    ZebraScanner.dispose();  // Don't do this!
    super.dispose();
  }
}
```

## Error Handling

### ✅ Do: Use Try-Catch
```dart
Future<void> startScanning() async {
  try {
    await ZebraScanner.startScan();
  } catch (e) {
    print('Error: $e');
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to start scanning: $e')),
    );
  }
}
```

### ❌ Don't: Ignore Errors
```dart
// Bad - errors are silently ignored
Future<void> startScanning() async {
  await ZebraScanner.startScan();  // What if this fails?
}
```

## Status Checking

### ✅ Do: Check Status Before Actions
```dart
Future<void> toggleScan() async {
  if (ZebraScanner.currentStatus == ScannerStatus.scanning) {
    await ZebraScanner.stopScan();
  } else if (ZebraScanner.currentStatus == ScannerStatus.ready) {
    await ZebraScanner.startScan();
  }
}
```

### ❌ Don't: Assume Scanner State
```dart
// Bad - might fail if scanner is not ready
Future<void> scan() async {
  await ZebraScanner.startScan();  // What if already scanning?
}
```

## UI Updates

### ✅ Do: Use setState with Streams
```dart
class _MyPageState extends State<MyPage> {
  String _barcode = '';
  
  @override
  void initState() {
    super.initState();
    ZebraScanner.scanResultStream.listen((result) {
      setState(() {
        _barcode = result.data;
      });
    });
  }
}
```

### ❌ Don't: Update UI Without setState
```dart
// Bad - UI won't update
class _MyPageState extends State<MyPage> {
  String _barcode = '';
  
  @override
  void initState() {
    super.initState();
    ZebraScanner.scanResultStream.listen((result) {
      _barcode = result.data;  // Missing setState!
    });
  }
}
```

## Navigation

### ✅ Do: Keep Scanner Initialized Across Pages
```dart
// Page 1
class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Page2()),
        );
        // Scanner stays initialized
      },
      child: Text('Next Page'),
    );
  }
}

// Page 2 - can use scanner immediately
class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => ZebraScanner.startScan(),
      child: Text('Scan'),
    );
  }
}
```

### ❌ Don't: Reinitialize on Every Page
```dart
// Bad - unnecessary reinitialization
class Page2 extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    ZebraScanner.initialize();  // Already initialized!
  }
}
```

## Performance

### ✅ Do: Debounce Rapid Scans
```dart
import 'dart:async';

class _MyPageState extends State<MyPage> {
  Timer? _debounce;
  
  @override
  void initState() {
    super.initState();
    ZebraScanner.scanResultStream.listen((result) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        processBarcode(result.data);
      });
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

### ❌ Don't: Process Every Scan Immediately
```dart
// Bad - might process duplicate scans
ZebraScanner.scanResultStream.listen((result) {
  processBarcode(result.data);  // Processes every scan
});
```

## Memory Management

### ✅ Do: Limit History Size
```dart
class _MyPageState extends State<MyPage> {
  final List<ScanResult> _history = [];
  final int _maxHistory = 100;
  
  void addToHistory(ScanResult result) {
    setState(() {
      _history.insert(0, result);
      if (_history.length > _maxHistory) {
        _history.removeLast();
      }
    });
  }
}
```

### ❌ Don't: Store Unlimited History
```dart
// Bad - memory leak with unlimited growth
class _MyPageState extends State<MyPage> {
  final List<ScanResult> _history = [];
  
  void addToHistory(ScanResult result) {
    _history.add(result);  // Grows forever!
  }
}
```

## Testing

### ✅ Do: Mock the Scanner for Tests
```dart
// Create a mock scanner for testing
class MockZebraScanner {
  static final _controller = StreamController<ScanResult>.broadcast();
  
  static Stream<ScanResult> get scanResultStream => _controller.stream;
  
  static void simulateScan(String barcode) {
    _controller.add(ScanResult(
      data: barcode,
      timestamp: DateTime.now(),
    ));
  }
}

// Use in tests
testWidgets('handles scan result', (tester) async {
  await tester.pumpWidget(MyApp());
  MockZebraScanner.simulateScan('123456');
  await tester.pump();
  expect(find.text('123456'), findsOneWidget);
});
```

## Architecture Patterns

### ✅ Do: Use BLoC or Provider Pattern
```dart
// Using Provider
class ScannerProvider extends ChangeNotifier {
  String _lastScan = '';
  
  ScannerProvider() {
    ZebraScanner.scanResultStream.listen((result) {
      _lastScan = result.data;
      notifyListeners();
    });
  }
  
  String get lastScan => _lastScan;
  
  Future<void> startScan() async {
    await ZebraScanner.startScan();
  }
}

// In widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScannerProvider>(
      builder: (context, scanner, child) {
        return Text(scanner.lastScan);
      },
    );
  }
}
```

### ✅ Do: Separate Business Logic
```dart
// Good - business logic separated
class ScannerService {
  Future<Product?> lookupProduct(String barcode) async {
    // Business logic here
    final response = await http.get(Uri.parse('api/products/$barcode'));
    return Product.fromJson(json.decode(response.body));
  }
}

// In widget
class _MyPageState extends State<MyPage> {
  final _scannerService = ScannerService();
  
  @override
  void initState() {
    super.initState();
    ZebraScanner.scanResultStream.listen((result) async {
      final product = await _scannerService.lookupProduct(result.data);
      // Update UI
    });
  }
}
```

## Security

### ✅ Do: Validate Barcode Data
```dart
bool isValidBarcode(String barcode) {
  // Validate format
  if (barcode.isEmpty || barcode.length > 100) {
    return false;
  }
  
  // Validate characters
  if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(barcode)) {
    return false;
  }
  
  return true;
}

ZebraScanner.scanResultStream.listen((result) {
  if (isValidBarcode(result.data)) {
    processBarcode(result.data);
  } else {
    showError('Invalid barcode format');
  }
});
```

### ❌ Don't: Trust All Input
```dart
// Bad - no validation
ZebraScanner.scanResultStream.listen((result) {
  processBarcode(result.data);  // What if it's malicious?
});
```

## Summary

### Key Principles

1. **Initialize once** - At app startup
2. **Cancel subscriptions** - In dispose()
3. **Handle errors** - Use try-catch
4. **Check status** - Before actions
5. **Validate input** - Don't trust blindly
6. **Limit memory** - Cap history size
7. **Separate concerns** - Business logic vs UI
8. **Test properly** - Use mocks

### Quick Checklist

- [ ] Initialize scanner once at app startup
- [ ] Store and cancel stream subscriptions
- [ ] Use try-catch for error handling
- [ ] Check scanner status before actions
- [ ] Update UI with setState
- [ ] Validate barcode data
- [ ] Limit history size
- [ ] Only dispose when app closes
- [ ] Separate business logic
- [ ] Write tests with mocks

### Common Mistakes to Avoid

1. ❌ Initializing in every widget
2. ❌ Not cancelling subscriptions
3. ❌ Calling dispose() too early
4. ❌ Ignoring errors
5. ❌ Not checking scanner status
6. ❌ Unlimited memory growth
7. ❌ No input validation
8. ❌ Business logic in widgets

---

**Follow these practices for a robust, maintainable scanner implementation!**
