import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/hasil_model.dart';
import '../models/result.dart';

class HasilService {
  late final Databases _db;

  HasilService({required Databases db}) : _db = db;

  Future<Result<HasilModel>> createHasil(HasilModel hasil) async {
    try {
      final jsonForCreate = toJsonForCreate(hasil);
      final document = await _db.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        documentId: 'unique()',
        data: jsonForCreate,
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      data['id'] = document.$id;
      return Result.success(HasilModel.fromJson(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> updateEmailForHasil(
    String oldEmail,
    String newEmail,
  ) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        queries: [Query.equal('email', oldEmail)],
      );

      for (final doc in documents.documents) {
        await _db.updateDocument(
          databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
          collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
          documentId: doc.$id,
          data: {'email': newEmail},
        );
      }

      return Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HasilModel>>> getAllHasil() async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        queries: [Query.orderDesc("\$createdAt")],
      );
      final hasilList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return HasilModel.fromJson(data);
      }).toList();
      return Result.success(hasilList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HasilModel>>> getAllHasilByGuruId(String guruId) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        queries: [
          Query.equal('guruId', guruId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      final hasilList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return HasilModel.fromJson(data);
      }).toList();
      return Result.success(hasilList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<HasilModel>>> getAllHasilByEmail(String email) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        queries: [Query.equal('email', email), Query.orderDesc("\$createdAt")],
      );
      final hasilList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return HasilModel.fromJson(data);
      }).toList();
      return Result.success(hasilList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<HasilModel>> getHasilById(String hasilId) async {
    try {
      final document = await _db.getDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        documentId: hasilId,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(
        document.data,
      );
      data['id'] = data['\$id'];
      data.remove('\$id');
      return Result.success(HasilModel.fromJson(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteHasil(String hasilId) async {
    try {
      await _db.deleteDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_HASIL_COLLECTION_ID']!,
        documentId: hasilId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  String getPublicImageUrl(String fileId) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
    final projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
    final bucketId = dotenv.env['APPWRITE_PROFILE_BUCKET_ID']!;
    return "$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId";
  }
}
