import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  late final Databases _db;
  late final Storage _storage;

  UserProfileService({required Databases db, required Storage storage})
    : _db = db,
      _storage = storage;

  Future<Result<UserProfile>> createUserProfile(UserProfile profile) async {
    try {
      final jsonForCreate = toJsonForCreate(profile);
      final document = await _db.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: profile.id,
        data: jsonForCreate,
      );
      return Result.success(UserProfile.fromJson(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<UserProfile>> getUserProfile(String userId) async {
    try {
      final document = await _db.getDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: userId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      data['id'] = data['\$id'];
      data.remove('\$id');
      return Result.success(UserProfile.fromJson(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<UserProfile>> updateUserProfile(UserProfile profile) async {
    try {
      final document = await _db.updateDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: profile.id,
        data: toJsonForCreate(profile),
      );

      final json = document.data;
      json['id'] = document.$id;

      return Result.success(UserProfile.fromJson(json));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<String?> uploadProfileImage(File file, String userId) async {
    try {
      final result = await _storage.createFile(
        bucketId: dotenv.env['APPWRITE_PROFILE_BUCKET_ID']!,
        fileId: 'profile_$userId',
        file: InputFile.fromPath(
          path: file.path,
          filename: 'profile_$userId.jpg',
        ),
      );
      return result.$id;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }

  Future<Result<void>> deleteProfileImage(String fileId) async {
    try {
      await _storage.deleteFile(
        bucketId: dotenv.env['APPWRITE_PROFILE_BUCKET_ID']!,
        fileId: fileId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failed('Delete failed: $e');
    }
  }

  String getPublicImageUrl(String fileId) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    final bucketId = dotenv.env['APPWRITE_PROFILE_BUCKET_ID']!;
    return "$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId";
  }
}
