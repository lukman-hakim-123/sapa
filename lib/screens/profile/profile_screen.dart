import 'dart:io';

import 'package:appwrite/models.dart' as models;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sapa/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _ulangiPasswordBaruController = TextEditingController();
  File? _pickedImage;
  bool _obscure = true;
  bool _obscure2 = true;
  bool _obscure3 = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final user = await ref.read(authProvider.future);
      if (user != null) {
        ref
            .read(userProfileNotifierProvider.notifier)
            .fetchUserProfile(user.$id);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final newFileName = 'profile_$timestamp.jpg';

      final tempDir = Directory.systemTemp;
      final newPath = '${tempDir.path}/$newFileName';
      final newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _pickedImage = newImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final url = ref
        .read(userProfileNotifierProvider.notifier)
        .getPublicImageUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }
          return userProfileState.when(
            data: (profile) {
              if (profile == null) {
                return const Center(child: Text("Can't fetch profile"));
              }

              _namaController.text = profile.nama;
              _emailController.text = profile.email;

              return _buildProfileUI(context, user, profile, false, url);
            },
            loading: () => _buildProfileUI(context, user, null, true, url),
            error: (err, _) => Center(child: Text("Error: $err")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  Widget _buildProfileUI(
    BuildContext context,
    models.User user,
    UserProfile? profile,
    bool isLoading,
    String Function(String) url,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 60),
                  child: CustomText(
                    text: "Profil",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 55,
                  right: 16,
                  child: IconButton(
                    icon: Icon(Icons.logout, color: Colors.red),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: CustomText(
                            text: 'Konfirmasi Logout',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          content: CustomText(
                            text: 'Apakah Anda yakin ingin logout?',
                            fontSize: 16,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: CustomText(text: 'Batal', fontSize: 16),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: CustomText(
                                text: 'Ya',
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await ref.read(authProvider.notifier).logout();
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!mounted) return;
                        context.go('/login');
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: -45,
                  left: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 53,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: _pickedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : ((profile!.foto.isNotEmpty || profile.foto != '')
                                ? ClipOval(
                                    child: Image.network(
                                      url(profile.foto),
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
              onPressed: _pickImage,
              child: const Text("Ganti Foto"),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 25.0),
                      CustomText(
                        text: 'Nama Lengkap',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  CustomTextFormField(
                    controller: _namaController,
                    validator: (value) =>
                        ValidationHelper.validateNotEmpty(value, 'Nama'),
                  ),
                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      Icon(Icons.email, size: 25.0),
                      CustomText(text: 'Email', fontWeight: FontWeight.bold),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomTextFormField(
                    controller: _emailController,
                    validator: (value) => ValidationHelper.validateEmail(value),
                  ),
                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      Icon(Icons.lock, size: 25),
                      CustomText(
                        text: 'Password lama',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomTextFormField(
                    controller: _passwordLamaController,
                    obscureText: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (value) =>
                        ValidationHelper.validateMultiple(value, [
                          (v) => ValidationHelper.validatePasswordOnEmailChange(
                            v,
                            profile!.email,
                            _emailController.text,
                          ),
                          (v) {
                            if (_passwordBaruController.text.isNotEmpty &&
                                (v == null || v.isEmpty)) {
                              return 'Password lama harus diisi';
                            }
                            return null;
                          },

                          (v) => ValidationHelper.validateOptionalMinLength(
                            v,
                            8,
                            'Password lama',
                          ),
                        ]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.lock, size: 25),
                      CustomText(
                        text: 'Password Baru',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomTextFormField(
                    controller: _passwordBaruController,
                    obscureText: _obscure2,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    validator: (value) =>
                        ValidationHelper.validateMultiple(value, [
                          (v) => ValidationHelper.validateOptionalMinLength(
                            v,
                            8,
                            'Password Baru',
                          ),
                        ]),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Icon(Icons.lock, size: 25),
                      CustomText(
                        text: 'Ulangi Password Baru',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomTextFormField(
                    controller: _ulangiPasswordBaruController,
                    obscureText: _obscure3,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure3 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure3 = !_obscure3),
                    ),
                    validator: (value) =>
                        ValidationHelper.validateMultiple(value, [
                          (v) => ValidationHelper.validateOptionalMinLength(
                            v,
                            8,
                            'Ulangi Password Baru',
                          ),
                          (v) {
                            if (v != _passwordBaruController.text) {
                              return 'Password baru tidak sama';
                            }
                            return null;
                          },
                        ]),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Edit Profil',
                    isLoading: isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        try {
                          final result = await ref
                              .read(userProfileNotifierProvider.notifier)
                              .updateUserProfileAdvanced(
                                profile!,
                                updatedProfile: UserProfile(
                                  id: profile.id,
                                  nama: _namaController.text,
                                  email: _emailController.text,
                                  foto: '',
                                  level_user: profile.level_user,
                                ),
                                photoFile: _pickedImage,
                                oldPassword:
                                    _passwordLamaController.text.isNotEmpty
                                    ? _passwordLamaController.text
                                    : null,
                                newPassword:
                                    _passwordBaruController.text.isNotEmpty
                                    ? _passwordBaruController.text
                                    : null,
                              );

                          if (!context.mounted) return;

                          if (result.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil berhasil diperbarui'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal: ${result.errorMessage}'),
                              ),
                            );
                          }
                        } finally {
                          _passwordLamaController.clear();
                          _passwordBaruController.clear();
                          _ulangiPasswordBaruController.clear();
                          _pickedImage = null;
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100.0),
          ],
        ),
      ),
    );
  }
}
