import 'package:freezed_annotation/freezed_annotation.dart';

part 'hasil_model.freezed.dart';
part 'hasil_model.g.dart';

@freezed
class HasilModel with _$HasilModel {
  factory HasilModel({
    required String id,
    required String anakId,
    required String namaAnak,
    required String imageId,
    required String email,
    required String guruId,
    required String namaGuru,
    required String kategori,
    required String tanggal,
    required int usia,
    required String kesimpulan,
    required String rekomendasi,
    required String jawaban,
  }) = _HasilModel;

  factory HasilModel.fromJson(Map<String, dynamic> json) =>
      _$HasilModelFromJson(json);
}

Map<String, dynamic> toJsonForCreate(HasilModel hasilModel) {
  final json = hasilModel.toJson();
  json.remove('id');
  return json;
}
