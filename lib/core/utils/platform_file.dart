import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Platform-safe representation of an image or file asset that works across Web, Android, iOS, and Desktop.
class AppPlatformFile {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final int size;

  const AppPlatformFile({
    required this.name,
    this.path,
    this.bytes,
    required this.size,
  });

  /// Factory creating [AppPlatformFile] asynchronously from an [XFile] (from ImagePicker or FilePicker).
  static Future<AppPlatformFile> fromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    return AppPlatformFile(
      name: file.name,
      path: file.path,
      bytes: bytes,
      size: bytes.length,
    );
  }

  /// Returns an [ImageProvider] that does not rely on dart:io File paths.
  ImageProvider? toImageProvider() {
    if (bytes != null && bytes!.isNotEmpty) {
      return MemoryImage(bytes!);
    }
    return null;
  }
}
