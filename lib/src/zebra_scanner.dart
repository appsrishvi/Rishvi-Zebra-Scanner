import 'dart:async';
import 'package:flutter/services.dart';
import 'models/scan_result.dart';
import 'models/scanner_status.dart';

/// Main class for Zebra Scanner Plugin
///
/// Provides methods to:
/// - Initialize the scanner
/// - Start/Stop scanning
/// - Listen to scan results
class ZebraScanner {
  static const MethodChannel _channel = MethodChannel('zebra_barcode_scanner');

  // Stream controllers
  static StreamController<ScanResult>? _scanResultController;
  static StreamController<ScannerStatus>? _statusController;

  static bool _isInitialized = false;
  static ScannerStatus _currentStatus = ScannerStatus.uninitialized;

  /// Stream of scan results
  static Stream<ScanResult> get scanResultStream {
    _scanResultController ??= StreamController<ScanResult>.broadcast();
    return _scanResultController!.stream;
  }

  /// Stream of scanner status changes
  static Stream<ScannerStatus> get statusStream {
    _statusController ??= StreamController<ScannerStatus>.broadcast();
    return _statusController!.stream;
  }

  /// Get current scanner status
  static ScannerStatus get currentStatus => _currentStatus;

  /// Check if scanner is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the Zebra Scanner
  ///
  /// This sets up the DataWedge profile and prepares the scanner for use.
  /// Must be called before using other methods.
  ///
  /// Returns true if initialization was successful
  static Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // Ensure controllers are created
      _scanResultController ??= StreamController<ScanResult>.broadcast();
      _statusController ??= StreamController<ScannerStatus>.broadcast();

      _channel.setMethodCallHandler(_handleMethodCall);

      await _channel.invokeMethod('initializeScanner');

      _isInitialized = true;
      _updateStatus(ScannerStatus.ready);

      return true;
    } on PlatformException catch (e) {
      _updateStatus(ScannerStatus.error);
      throw Exception('Failed to initialize scanner: ${e.message}');
    }
  }

  /// Start scanning for barcodes
  ///
  /// Triggers the soft scan trigger on the Zebra device.
  /// Scanner must be initialized before calling this method.
  ///
  /// Returns true if scanning started successfully
  static Future<bool> startScan() async {
    if (!_isInitialized) {
      throw Exception('Scanner not initialized. Call initialize() first.');
    }

    try {
      await _channel.invokeMethod('startScanning');
      _updateStatus(ScannerStatus.scanning);
      return true;
    } on PlatformException catch (e) {
      _updateStatus(ScannerStatus.error);
      throw Exception('Failed to start scanning: ${e.message}');
    }
  }

  /// Stop scanning
  ///
  /// Stops the soft scan trigger on the Zebra device.
  ///
  /// Returns true if scanning stopped successfully
  static Future<bool> stopScan() async {
    if (!_isInitialized) {
      throw Exception('Scanner not initialized. Call initialize() first.');
    }

    try {
      await _channel.invokeMethod('stopScanning');
      _updateStatus(ScannerStatus.ready);
      return true;
    } on PlatformException catch (e) {
      _updateStatus(ScannerStatus.error);
      throw Exception('Failed to stop scanning: ${e.message}');
    }
  }

  /// Handle method calls from native platform
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onScanResult':
        if (call.arguments is Map) {
          final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
            call.arguments,
          );
          final scanResult = ScanResult.fromMap(resultMap);

          // Only add if controller is not closed
          if (_scanResultController != null &&
              !_scanResultController!.isClosed) {
            _scanResultController!.add(scanResult);
          }

          // Auto-stop after successful scan
          _updateStatus(ScannerStatus.ready);
        }
        break;

      case 'onStatusChange':
        if (call.arguments is String) {
          final status = ScannerStatusExtension.fromString(call.arguments);
          _updateStatus(status);
        }
        break;
    }
  }

  /// Update scanner status and notify listeners
  static void _updateStatus(ScannerStatus status) {
    _currentStatus = status;

    // Only add if controller exists and is not closed
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.add(status);
    }
  }

  /// Dispose resources and clean up
  ///
  /// Should be called when the scanner is no longer needed
  static void dispose() {
    _isInitialized = false;
    _currentStatus = ScannerStatus.uninitialized;

    _scanResultController?.close();
    _scanResultController = null;

    _statusController?.close();
    _statusController = null;
  }
}
