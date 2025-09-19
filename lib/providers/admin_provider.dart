import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sapa/models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../services/admin_service.dart';
import '../utils/provider.dart';
import 'user_profile_provider.dart';

part 'admin_provider.g.dart';

@riverpod
class AdminNotifier extends _$AdminNotifier {
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );
  late final AdminService _adminService = AdminService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<UserProfile>> build() async {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    if (profileAsync.isLoading) {
      state = const AsyncValue.loading();
    }
    if (profileAsync.hasError) {
      throw profileAsync.error!;
    }

    final profile = profileAsync.value;
    if (profile == null) return [];

    final result = await _adminService.getAllAdmin();
    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
    }
  }

  Future<void> createAdmin(
    String nama,
    String email,
    String password,
    String sekolah,
  ) async {
    state = const AsyncValue.loading();
    try {
      final authResult = await _authService.createAccount(
        email: email,
        password: password,
      );

      if (!authResult.isSuccess) {
        throw Exception("Gagal membuat akun Admin: ${authResult.errorMessage}");
      }

      final userId = authResult.resultValue?.$id ?? '';
      if (userId.isEmpty) {
        throw Exception("User ID dari Appwrite kosong");
      }

      final adminProfile = UserProfile(
        id: userId,
        nama: nama,
        email: email,
        foto: '',
        levelUser: 1,
        sekolah: sekolah,
      );

      final result = await _adminService.createAdmin(adminProfile);

      if (result.isSuccess) {
        state = AsyncValue.data([...state.value ?? [], result.resultValue!]);
      } else {
        throw Exception("Gagal menyimpan Admin: ${result.errorMessage}");
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchAdminById(String adminId) async {
    state = const AsyncValue.loading();
    final result = await _adminService.getAdminById(adminId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateAdmin(UserProfile updatedAdmin) async {
    state = const AsyncValue.loading();
    try {
      final result = await _adminService.updateAdmin(updatedAdmin);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((admin) {
          return admin.id == updatedAdmin.id ? updatedAdmin : admin;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteAdmin(UserProfile admin) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _adminService.deleteProfileImage(admin.foto);
      final result = await _adminService.deleteAdmin(admin.id);

      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((g) => g.id != admin.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String getPublicImageUrl(String fileId) {
    return _adminService.getPublicImageUrl(fileId);
  }
}
