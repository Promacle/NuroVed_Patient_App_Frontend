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

  /// Extracts file extension in lowercase without leading dot (e.g. 'pdf', 'png', 'jpg').
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  /// Inferred MIME type based on file extension and/or header bytes.
  String get mimeType {
    final ext = extension;
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  bool get isPdf => extension == 'pdf';
  bool get isImage => extension == 'jpg' || extension == 'jpeg' || extension == 'png';

  /// Factory creating [AppPlatformFile] asynchronously from an [XFile] (from ImagePicker or Camera).
  static Future<AppPlatformFile> fromXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    return AppPlatformFile(
      name: file.name,
      path: kIsWeb ? null : file.path,
      bytes: bytes,
      size: bytes.length,
    );
  }

  /// Factory creating [AppPlatformFile] safely from a `file_picker` PlatformFile.
  /// Never accesses `dart:io.File` on web.
  static Future<AppPlatformFile> fromPlatformFile(dynamic platformFile) async {
    Uint8List? fileBytes;
    if (platformFile.bytes != null) {
      fileBytes = platformFile.bytes as Uint8List;
    }

    final int fileSize = fileBytes?.length ?? (platformFile.size as int? ?? 0);
    return AppPlatformFile(
      name: platformFile.name as String? ?? 'document',
      path: kIsWeb ? null : platformFile.path as String?,
      bytes: fileBytes,
      size: fileSize,
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

/// Token used to signal cancellation of an in-flight storage upload.
class UploadCancelToken {
  bool _isCancelled = false;
  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

