import 'dart:math';

/// Lightweight, cryptographically secure RFC 4122 v4 UUID generator.
class UuidGenerator {
  UuidGenerator._();

  static final Random _secureRandom = Random.secure();

  /// Generates a standard 36-character v4 UUID (e.g. 550e8400-e29b-41d4-a716-446655440000).
  static String v4() {
    final values = List<int>.generate(16, (_) => _secureRandom.nextInt(256));

    // Set version to 4 (bits 12-15 of time_hi_and_version to 0100)
    values[6] = (values[6] & 0x0f) | 0x40;
    // Set variant to RFC 4122 (bits 6-7 of clock_seq_hi_and_reserved to 10)
    values[8] = (values[8] & 0x3f) | 0x80;

    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      final hex = values[i].toRadixString(16).padLeft(2, '0');
      buffer.write(hex);
    }
    return buffer.toString();
  }
}
