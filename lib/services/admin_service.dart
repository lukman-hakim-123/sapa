import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/user_profile_model.dart';

class AdminService {
  late final Databases _db;
  late final Storage _storage;

  AdminService({required Databases db, required Storage storage})
    : _db = db,
      _storage = storage;

  Future<Result<UserProfile>> createAdmin(UserProfile admin) async {
    try {
      final jsonForCreate = toJsonForCreate(admin);
      final document = await _db.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: admin.id,
        data: jsonForCreate,
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      data['id'] = document.$id;
      return Result.success(UserProfile.fromJson(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<UserProfile>>> getAllAdmin() async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        queries: [Query.equal('levelUser', 1)],
      );
      final AdminList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return UserProfile.fromJson(data);
      }).toList();
      return Result.success(AdminList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<UserProfile>> getAdminById(String adminId) async {
    try {
      final document = await _db.getDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: adminId,
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

  Future<Result<UserProfile>> updateAdmin(UserProfile admin) async {
    try {
      final jsonForCreate = toJsonForCreate(admin);
      final document = await _db.updateDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: admin.id,
        data: jsonForCreate,
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

  Future<Result<void>> deleteAdmin(String adminId) async {
    try {
      await _db.deleteDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USERS_COLLECTION_ID']!,
        documentId: adminId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<String?>> uploadProfileImage(File file, String userId) async {
    try {
      final result = await _storage.createFile(
        bucketId: dotenv.env['APPWRITE_PROFILE_BUCKET_ID']!,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: userId),
      );
      return Result.success(result.$id);
    } catch (e) {
      return Result.failed(e.toString());
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
