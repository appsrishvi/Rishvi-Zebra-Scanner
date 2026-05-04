/// Enum representing the scanner status
enum ScannerStatus {
  /// Scanner is not initialized
  uninitialized,

  /// Scanner is ready to scan
  ready,

  /// Scanner is currently scanning
  scanning,

  /// Scanner encountered an error
  error,

  /// Scanner is disabled
  disabled,
}

/// Extension to convert string to ScannerStatus
extension ScannerStatusExtension on ScannerStatus {
  String get name {
    switch (this) {
      case ScannerStatus.uninitialized:
        return 'uninitialized';
      case ScannerStatus.ready:
        return 'ready';
      case ScannerStatus.scanning:
        return 'scanning';
      case ScannerStatus.error:
        return 'error';
      case ScannerStatus.disabled:
        return 'disabled';
    }
  }

  static ScannerStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'ready':
        return ScannerStatus.ready;
      case 'scanning':
        return ScannerStatus.scanning;
      case 'error':
        return ScannerStatus.error;
      case 'disabled':
        return ScannerStatus.disabled;
      default:
        return ScannerStatus.uninitialized;
    }
  }
}
