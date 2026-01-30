import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// Firebase Storage Service
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload a file to Firebase Storage
  Future<PatientDocument?> uploadFile({
    required String patientId,
    required File file,
    required String fileName,
  }) async {
    try {
      // Get file extension
      final extension = path.extension(fileName).toLowerCase();

      // Generate unique filename
      final uniqueFileName = '${_uuid.v4()}$extension';
      final storagePath = 'patients/$patientId/documents/$uniqueFileName';

      // Compress image if it's an image file
      File fileToUpload = file;
      if (['.jpg', '.jpeg', '.png'].contains(extension)) {
        final compressedFile = await _compressImage(file);
        if (compressedFile != null) {
          fileToUpload = compressedFile;
        }
      }

      // Upload file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(fileToUpload);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Get file size
      final fileSize = await fileToUpload.length();

      return PatientDocument(
        id: _uuid.v4(),
        fileName: fileName,
        fileUrl: downloadUrl,
        fileType: extension.replaceFirst('.', ''),
        fileSize: fileSize,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Upload multiple files
  Future<List<PatientDocument>> uploadFiles({
    required String patientId,
    required List<File> files,
    required List<String> fileNames,
  }) async {
    final documents = <PatientDocument>[];

    for (int i = 0; i < files.length; i++) {
      final document = await uploadFile(
        patientId: patientId,
        file: files[i],
        fileName: fileNames[i],
      );
      if (document != null) {
        documents.add(document);
      }
    }

    return documents;
  }

  /// Delete a file from Firebase Storage
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Compress image file
  Future<File?> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jpg|.jpeg|.png'));
      final splitted = filePath.substring(0, lastIndex);
      final outPath = '${splitted}_compressed${filePath.substring(lastIndex)}';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      return null;
    }
  }

  /// Get file download URL
  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
