import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  factory UserProfile({
    required String id,
    required String nama,
    required String email,
    required String foto,
    required int level_user,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

Map<String, dynamic> toJsonForCreate(UserProfile profile) {
  final json = profile.toJson();
  json.remove('id');
  return json;
}
