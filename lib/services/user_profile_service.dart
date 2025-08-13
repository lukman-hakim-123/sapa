import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/user_profile_model.dart';

class UserProfileService {
  late final Databases _db;

  UserProfileService({required Databases db}) : _db = db;

  Future<Result<UserProfile>> createUserProfile(UserProfile profile) async {
    try {
      final jsonForCreate = toJsonForCreate(profile);
      final document = await _db.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_USER_PROFILE_COLLECTION_ID']!,
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
        collectionId: dotenv.env['APPWRITE_USER_PROFILE_COLLECTION_ID']!,
        documentId: userId,
      );
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(document.data);
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
        collectionId: dotenv.env['APPWRITE_USER_PROFILE_COLLECTION_ID']!,
        documentId: profile.id,
        data: profile.toJson(),
      );
      return Result.success(UserProfile.fromJson(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
