import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the plugin channel so the example app can render without a device
  const channel = MethodChannel('zebra_barcode_scanner');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'initializeScanner':
          return 'Scanner initialized';
        case 'startScanning':
          return 'Scanning started';
        case 'stopScanning':
          return 'Scanning stopped';
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Example app renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    expect(find.text('Zebra Scanner Examples'), findsOneWidget);
  });

  testWidgets('Home page shows all four example cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    expect(find.text('Basic Scanner'), findsOneWidget);
    expect(find.text('Inventory Scanner'), findsOneWidget);
    expect(find.text('Batch Scanner'), findsOneWidget);
    expect(find.text('Product Lookup'), findsOneWidget);
  });

  testWidgets('Tapping Basic Scanner navigates to BasicScannerExample',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    await tester.tap(find.text('Basic Scanner'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Scanner'), findsWidgets);
  });

  testWidgets('Tapping Inventory Scanner navigates to InventoryScannerExample',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    await tester.tap(find.text('Inventory Scanner'));
    await tester.pumpAndSettle();

    expect(find.text('Inventory Scanner'), findsWidgets);
  });

  testWidgets('Tapping Batch Scanner navigates to BatchScannerExample',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    await tester.tap(find.text('Batch Scanner'));
    await tester.pumpAndSettle();

    expect(find.text('Batch Scanner'), findsWidgets);
  });

  testWidgets('Tapping Product Lookup navigates to ProductLookupExample',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZebraScannerExampleApp());
    await tester.pump();

    await tester.tap(find.text('Product Lookup'));
    await tester.pumpAndSettle();

    expect(find.text('Product Lookup'), findsWidgets);
  });
}
