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

  const ScanResult({
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

  /// Returns a copy of this [ScanResult] with the given fields replaced.
  ScanResult copyWith({
    String? data,
    String? type,
    DateTime? timestamp,
    String? source,
  }) {
    return ScanResult(
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResult &&
        other.data == data &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.source == source;
  }

  @override
  int get hashCode =>
      data.hashCode ^ type.hashCode ^ timestamp.hashCode ^ source.hashCode;

  @override
  String toString() {
    return 'ScanResult(data: $data, type: $type, timestamp: $timestamp, source: $source)';
  }
}
