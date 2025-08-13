import 'package:freezed_annotation/freezed_annotation.dart';

part 'produk_model.freezed.dart';
part 'produk_model.g.dart';

@freezed
class ProdukModel with _$ProdukModel {
  factory ProdukModel({
    required String id,                
    required String userId,                
    required String namaProduk,              
    required String deskripsi,            
    required String sku,                    
    required double hargaPokok,                   
    required double hargaJual,                      
    required double jumlah,                 
    required String jenis,                  
  }) = _ProdukModel;

  factory ProdukModel.fromJson(Map<String, dynamic> json) =>
      _$ProdukModelFromJson(json);

}

Map<String, dynamic> toJsonForCreate(ProdukModel produk) {
  final json = produk.toJson(); 
  json.remove('id');
  return json;
}
