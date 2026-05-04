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

/// Extension to convert string to [ScannerStatus] and provide helpers
extension ScannerStatusExtension on ScannerStatus {
  /// Human-readable label for this status.
  ///
  /// Use this instead of `.name` when you need a display string, as `.name`
  /// is Dart's built-in enum name getter.
  String get statusLabel {
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

  /// Returns true if the scanner is actively scanning.
  bool get isScanning => this == ScannerStatus.scanning;

  /// Returns true if the scanner is ready to accept a scan trigger.
  bool get isReady => this == ScannerStatus.ready;

  /// Returns true if the scanner has been successfully initialized.
  bool get isInitialized => this != ScannerStatus.uninitialized;

  /// Parse a [ScannerStatus] from a string value (case-insensitive).
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
