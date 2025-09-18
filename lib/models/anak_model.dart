import 'package:freezed_annotation/freezed_annotation.dart';

part 'anak_model.freezed.dart';
part 'anak_model.g.dart';

@freezed
class AnakModel with _$AnakModel {
  factory AnakModel({
    required String id,
    required String guruId,
    required String nama,
    required String namaAyah,
    required String namaIbu,
    required String email,
    required String tempatLahir,
    required String tanggalLahir,
    required int usia,
    required String jenisKelamin,
    required String alamat,
    required String imageId,
    required String sekolah,
    String? $createdAt,
    String? $updatedAt,
  }) = _AnakModel;

  factory AnakModel.fromJson(Map<String, dynamic> json) =>
      _$AnakModelFromJson(json);
}

Map<String, dynamic> toJsonForCreate(AnakModel anakModel) {
  final json = anakModel.toJson();
  json.remove('id');
  return json;
}
