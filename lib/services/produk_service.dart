import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result.dart';
import '../models/produk_model.dart';

class ProdukService {
  late final Databases _db;

  ProdukService({required Databases db}) : _db = db;

  Future<Result<ProdukModel>> createProduk(ProdukModel produk) async {
    try {
      final jsonForCreate = toJsonForCreate(produk);
      final document = await _db.createDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_PRODUK_COLLECTION_ID']!,
        documentId: 'unique()', 
        data: jsonForCreate,
      );
      return Result.success(ProdukModel.fromJson(document.data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<List<ProdukModel>>> getAllProduk() async {
  try {
    final documents = await _db.listDocuments(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
      collectionId: dotenv.env['APPWRITE_PRODUK_COLLECTION_ID']!,
    );
    final produkList = documents.documents.map((doc) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(doc.data);
      data['id'] = data['\$id'];
      data.remove('\$id'); // Opsional, hanya jika Anda ingin menghapus field \$id
      return ProdukModel.fromJson(data);
    }).toList();
    return Result.success(produkList);
  } catch (e) {
    return Result.failed(e.toString());
  }
}


  Future<Result<ProdukModel>> getProdukById(String produkId) async {
  try {
    final document = await _db.getDocument(
      databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
      collectionId: dotenv.env['APPWRITE_PRODUK_COLLECTION_ID']!,
      documentId: produkId,
    );
    final Map<String, dynamic> data = Map<String, dynamic>.from(document.data);
    data['id'] = data['\$id'];
    data.remove('\$id'); // Opsional, hanya jika Anda ingin menghapus field \$id
    return Result.success(ProdukModel.fromJson(data));
  } catch (e) {
    return Result.failed(e.toString());
  }
}


  Future<Result<ProdukModel>> updateProduk(ProdukModel produk) async {
    try {
            final jsonForCreate = toJsonForCreate(produk);
      final document = await _db.updateDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_PRODUK_COLLECTION_ID']!,
        documentId: produk.id,
        data: jsonForCreate,
      );
      final Map<String, dynamic> data = Map<String, dynamic>.from(document.data);
    data['id'] = data['\$id'];
    data.remove('\$id');
      return Result.success(ProdukModel.fromJson(data));
    } catch (e) {
      return Result.failed(e.toString());
    }
  }

  Future<Result<void>> deleteProduk(String produkId) async {
    try {
      await _db.deleteDocument(
        databaseId: dotenv.env['APPWRITE_DATABASE_ID']!,
        collectionId: dotenv.env['APPWRITE_PRODUK_COLLECTION_ID']!,
        documentId: produkId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failed(e.toString());
    }
  }
}
