import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/core/utils/validators.dart';

void main() {
  group('Medical Document File Validation & Signature Verification', () {
    test('accepts valid PDF with %PDF magic bytes', () {
      final pdfBytes = Uint8List.fromList([
        0x25, 0x50, 0x44, 0x46, 0x2D, // %PDF-
        0x31, 0x2E, 0x34, 0x0A,
      ]);
      final file = AppPlatformFile(
        name: 'blood_test.pdf',
        size: pdfBytes.length,
        bytes: pdfBytes,
      );

      final error = Validators.validateMedicalDocument(
        fileName: file.name,
        byteLength: file.size,
        bytes: file.bytes,
      );
      expect(error, isNull);
    });

    test('accepts valid JPEG with 0xFF, 0xD8, 0xFF header', () {
      final jpegBytes = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46,
      ]);
      final file = AppPlatformFile(
        name: 'prescription.jpg',
        size: jpegBytes.length,
        bytes: jpegBytes,
      );

      final error = Validators.validateMedicalDocument(
        fileName: file.name,
        byteLength: file.size,
        bytes: file.bytes,
      );
      expect(error, isNull);
    });

    test('accepts valid PNG with standard 8-byte magic header', () {
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00,
      ]);
      final file = AppPlatformFile(
        name: 'xray.png',
        size: pngBytes.length,
        bytes: pngBytes,
      );

      final error = Validators.validateMedicalDocument(
        fileName: file.name,
        byteLength: file.size,
        bytes: file.bytes,
      );
      expect(error, isNull);
    });

    test('rejects spoofed file (text content named as .pdf)', () {
      final fakeBytes = Uint8List.fromList('Hello World plain text'.codeUnits);
      final file = AppPlatformFile(
        name: 'malicious.pdf',
        size: fakeBytes.length,
        bytes: fakeBytes,
      );

      final error = Validators.validateMedicalDocument(
        fileName: file.name,
        byteLength: file.size,
        bytes: file.bytes,
      );
      expect(error, contains('Invalid PDF'));
    });

    test('rejects spoofed file (plain text named as .jpg)', () {
      final fakeBytes = Uint8List.fromList('Not a real image file'.codeUnits);
      final file = AppPlatformFile(
        name: 'fake.jpg',
        size: fakeBytes.length,
        bytes: fakeBytes,
      );

      final error = Validators.validateMedicalDocument(
        fileName: file.name,
        byteLength: file.size,
        bytes: file.bytes,
      );
      expect(error, contains('Invalid JPEG'));
    });

    test('rejects file exceeding 10MB limit', () {
      final oversizedLength = 10 * 1024 * 1024 + 1024; // 10MB + 1KB
      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D]);

      final error = Validators.validateMedicalDocument(
        fileName: 'huge_scan.pdf',
        byteLength: oversizedLength,
        bytes: pdfBytes,
      );
      expect(error, contains('exceeds maximum allowed limit of 10.0MB'));
    });

    test('rejects empty file (0 bytes)', () {
      final error = Validators.validateMedicalDocument(
        fileName: 'empty.pdf',
        byteLength: 0,
        bytes: Uint8List(0),
      );
      expect(error, contains('cannot be empty'));
    });

    test('rejects unsupported extensions', () {
      final exeBytes = Uint8List.fromList([0x4D, 0x5A]); // MZ
      final error = Validators.validateMedicalDocument(
        fileName: 'program.exe',
        byteLength: exeBytes.length,
        bytes: exeBytes,
      );
      expect(error, contains('not allowed'));
    });

    test('rejects files without extension', () {
      final error = Validators.validateMedicalDocument(
        fileName: 'somefile',
        byteLength: 100,
        bytes: Uint8List(100),
      );
      expect(error, contains('no extension'));
    });
  });
}
