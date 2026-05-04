/// Model class representing a barcode scan result
class ScanResult {
  /// The scanned barcode data
  final String data;

  /// The barcode type (e.g., QR Code, EAN-13, Code 128)
  final String? type;

  /// Timestamp when the scan occurred
  final DateTime timestamp;

  /// Source of the scan (e.g., 'barcode_scan', 'manual')
  final String? source;

  ScanResult({
    required this.data,
    this.type,
    required this.timestamp,
    this.source,
  });

  /// Create ScanResult from a map (from native platform)
  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      data: map['data'] as String? ?? '',
      type: map['type'] as String?,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      source: map['source'] as String?,
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source,
    };
  }

  @override
  String toString() {
    return 'ScanResult(data: $data, type: $type, timestamp: $timestamp, source: $source)';
  }
}
