import 'package:flutter/services.dart';

class ZebraScannerService {
  static const MethodChannel _channel = MethodChannel('zebra_barcode_scanner');
  static Function(String)? _onScanResult;

  /// Initialize the service and set up scan result callback
  static void initialize({Function(String)? onScanResult}) {
    _onScanResult = onScanResult;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle method calls from native Android
  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onScanResult':
        if (_onScanResult != null && call.arguments is Map) {
          final Map<String, dynamic> result = Map<String, dynamic>.from(
            call.arguments,
          );
          final String barcodeData = result['data'] ?? '';
          if (barcodeData.isNotEmpty) {
            _onScanResult!(barcodeData);
          }
        }
        break;
    }
  }

  /// Initialize the DataWedge scanner
  static Future<String> initializeScanner() async {
    try {
      final String result = await _channel.invokeMethod('initializeScanner');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize scanner: ${e.message}');
    }
  }

  /// Start barcode scanning (soft trigger)
  static Future<String> startScanning() async {
    try {
      final String result = await _channel.invokeMethod('startScanning');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to start scanning: ${e.message}');
    }
  }

  /// Stop barcode scanning
  static Future<String> stopScanning() async {
    try {
      final String result = await _channel.invokeMethod('stopScanning');
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop scanning: ${e.message}');
    }
  }

  /// Dispose resources
  static void dispose() {
    _onScanResult = null;
  }
}
