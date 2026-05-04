import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rishvi_zebra_scanner/zebra_scanner_plugin.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the MethodChannel so tests run without a real device
  const channel = MethodChannel('zebra_barcode_scanner');
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    // Reset plugin state before each test
    ZebraScanner.dispose();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      log.add(call);
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
    ZebraScanner.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  // ─── ScanResult model ────────────────────────────────────────────────────

  group('ScanResult', () {
    test('constructs with required fields', () {
      final now = DateTime.now();
      final result = ScanResult(data: '123456', timestamp: now);

      expect(result.data, '123456');
      expect(result.timestamp, now);
      expect(result.type, isNull);
      expect(result.source, isNull);
    });

    test('constructs with all fields', () {
      final now = DateTime.now();
      final result = ScanResult(
        data: '123456',
        type: 'EAN-13',
        timestamp: now,
        source: 'barcode_scan',
      );

      expect(result.data, '123456');
      expect(result.type, 'EAN-13');
      expect(result.source, 'barcode_scan');
    });

    test('fromMap parses all fields correctly', () {
      final now = DateTime.now();
      final map = {
        'data': 'ABC-001',
        'type': 'Code 128',
        'timestamp': now.millisecondsSinceEpoch,
        'source': 'barcode_scan',
      };

      final result = ScanResult.fromMap(map);

      expect(result.data, 'ABC-001');
      expect(result.type, 'Code 128');
      expect(result.source, 'barcode_scan');
      expect(
        result.timestamp.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });

    test('fromMap uses empty string when data is null', () {
      final result = ScanResult.fromMap({'timestamp': null});
      expect(result.data, '');
    });

    test('fromMap uses DateTime.now() when timestamp is null', () {
      final before = DateTime.now();
      final result = ScanResult.fromMap({'data': 'X', 'timestamp': null});
      final after = DateTime.now();

      expect(
        result.timestamp.isAfter(before) ||
            result.timestamp.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        result.timestamp.isBefore(after) ||
            result.timestamp.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('toMap round-trips correctly', () {
      final now = DateTime.now();
      final result = ScanResult(
        data: 'QR-DATA',
        type: 'QR Code',
        timestamp: now,
        source: 'manual',
      );

      final map = result.toMap();

      expect(map['data'], 'QR-DATA');
      expect(map['type'], 'QR Code');
      expect(map['timestamp'], now.millisecondsSinceEpoch);
      expect(map['source'], 'manual');
    });

    test('toString includes all fields', () {
      final now = DateTime.now();
      final result = ScanResult(
        data: 'TEST',
        type: 'EAN-8',
        timestamp: now,
        source: 'scan',
      );

      final str = result.toString();
      expect(str, contains('TEST'));
      expect(str, contains('EAN-8'));
      expect(str, contains('scan'));
    });
  });

  // ─── ScannerStatus enum ───────────────────────────────────────────────────

  group('ScannerStatus', () {
    test('fromString returns correct status for known values', () {
      expect(ScannerStatusExtension.fromString('ready'), ScannerStatus.ready);
      expect(
        ScannerStatusExtension.fromString('scanning'),
        ScannerStatus.scanning,
      );
      expect(ScannerStatusExtension.fromString('error'), ScannerStatus.error);
      expect(
        ScannerStatusExtension.fromString('disabled'),
        ScannerStatus.disabled,
      );
    });

    test('fromString is case-insensitive', () {
      expect(ScannerStatusExtension.fromString('READY'), ScannerStatus.ready);
      expect(
        ScannerStatusExtension.fromString('Scanning'),
        ScannerStatus.scanning,
      );
    });

    test('fromString returns uninitialized for unknown values', () {
      expect(
        ScannerStatusExtension.fromString('unknown'),
        ScannerStatus.uninitialized,
      );
      expect(
        ScannerStatusExtension.fromString(''),
        ScannerStatus.uninitialized,
      );
    });

    test('name extension returns correct string for each status', () {
      expect(ScannerStatus.uninitialized.name, 'uninitialized');
      expect(ScannerStatus.ready.name, 'ready');
      expect(ScannerStatus.scanning.name, 'scanning');
      expect(ScannerStatus.error.name, 'error');
      expect(ScannerStatus.disabled.name, 'disabled');
    });
  });

  // ─── ZebraScanner ─────────────────────────────────────────────────────────

  group('ZebraScanner', () {
    test('initial state is uninitialized', () {
      expect(ZebraScanner.isInitialized, isFalse);
      expect(ZebraScanner.currentStatus, ScannerStatus.uninitialized);
    });

    test('initialize() calls initializeScanner on channel', () async {
      await ZebraScanner.initialize();

      expect(log, hasLength(1));
      expect(log.first.method, 'initializeScanner');
    });

    test('initialize() sets isInitialized to true', () async {
      await ZebraScanner.initialize();
      expect(ZebraScanner.isInitialized, isTrue);
    });

    test('initialize() sets status to ready', () async {
      await ZebraScanner.initialize();
      expect(ZebraScanner.currentStatus, ScannerStatus.ready);
    });

    test('initialize() is idempotent — second call skips channel invoke',
        () async {
      await ZebraScanner.initialize();
      await ZebraScanner.initialize();

      // Channel should only be called once
      expect(log.where((c) => c.method == 'initializeScanner'), hasLength(1));
    });

    test('startScan() calls startScanning on channel', () async {
      await ZebraScanner.initialize();
      log.clear();

      await ZebraScanner.startScan();

      expect(log, hasLength(1));
      expect(log.first.method, 'startScanning');
    });

    test('startScan() sets status to scanning', () async {
      await ZebraScanner.initialize();
      await ZebraScanner.startScan();

      expect(ZebraScanner.currentStatus, ScannerStatus.scanning);
    });

    test('startScan() throws if not initialized', () async {
      expect(
        () => ZebraScanner.startScan(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not initialized'),
          ),
        ),
      );
    });

    test('stopScan() calls stopScanning on channel', () async {
      await ZebraScanner.initialize();
      await ZebraScanner.startScan();
      log.clear();

      await ZebraScanner.stopScan();

      expect(log, hasLength(1));
      expect(log.first.method, 'stopScanning');
    });

    test('stopScan() sets status back to ready', () async {
      await ZebraScanner.initialize();
      await ZebraScanner.startScan();
      await ZebraScanner.stopScan();

      expect(ZebraScanner.currentStatus, ScannerStatus.ready);
    });

    test('stopScan() throws if not initialized', () async {
      expect(
        () => ZebraScanner.stopScan(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not initialized'),
          ),
        ),
      );
    });

    test('dispose() resets state', () async {
      await ZebraScanner.initialize();
      ZebraScanner.dispose();

      expect(ZebraScanner.isInitialized, isFalse);
      expect(ZebraScanner.currentStatus, ScannerStatus.uninitialized);
    });

    test('scanResultStream emits result when native sends onScanResult',
        () async {
      await ZebraScanner.initialize();

      final now = DateTime.now();
      final payload = {
        'data': 'SCAN-001',
        'type': 'QR Code',
        'timestamp': now.millisecondsSinceEpoch,
        'source': 'barcode_scan',
      };

      // Collect the first emitted result
      final future = ZebraScanner.scanResultStream.first;

      // Simulate native → Flutter callback
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'zebra_barcode_scanner',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('onScanResult', payload),
        ),
        (_) {},
      );

      final result = await future;
      expect(result.data, 'SCAN-001');
      expect(result.type, 'QR Code');
    });

    test('statusStream emits status when native sends onStatusChange',
        () async {
      await ZebraScanner.initialize();

      final future = ZebraScanner.statusStream.first;

      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
        'zebra_barcode_scanner',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onStatusChange', 'scanning'),
        ),
        (_) {},
      );

      final status = await future;
      expect(status, ScannerStatus.scanning);
    });
  });
}
