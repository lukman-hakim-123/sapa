import 'package:freezed_annotation/freezed_annotation.dart';

part 'stppa_model.freezed.dart';
part 'stppa_model.g.dart';

@freezed
class StppaModel with _$StppaModel {
  factory StppaModel({
    required String id,
    required String kategori,
    required String indikator,
    required int usia,
    required int nomor,
    required String pernyataan,
    required String judul,
  }) = _StppaModel;

  factory StppaModel.fromJson(Map<String, dynamic> json) =>
      _$StppaModelFromJson(json);
}

Map<String, dynamic> toJsonForCreate(StppaModel stppaModel) {
  final json = stppaModel.toJson();
  json.remove('id');
  return json;
}
