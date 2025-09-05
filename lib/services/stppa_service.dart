import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/stppa_model.dart';

class StppaService {
  late final Databases _db;

  StppaService({required Databases db}) : _db = db;

  Future<Result<List<StppaModel>>> getAllStppaByKategori(
    String kategori,
    int usia,
  ) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_STPPA_COLLECTION_ID']!,
        queries: [
          Query.equal('kategori', kategori),
          Query.equal('usia', usia),
          Query.orderAsc("nomor"),
          Query.limit(100),
        ],
      );
      final stppaList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return StppaModel.fromJson(data);
      }).toList();
      return Result.success(stppaList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<StppaModel>>> getStppaBySubKategori(
    String subKategori,
    int usia,
  ) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_STPPA_COLLECTION_ID']!,
        queries: [
          Query.equal('subKategori', subKategori),
          Query.equal('usia', usia),
          Query.orderAsc("nomor"),
        ],
      );
      final stppaList = documents.documents.map((doc) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
        data['id'] = data['\$id'];
        data.remove('\$id');
        return StppaModel.fromJson(data);
      }).toList();
      return Result.success(stppaList);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
