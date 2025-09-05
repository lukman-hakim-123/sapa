import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../utils/build_context_extension.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state.value != null) {
        context.go('/bottomNav');
      } else if (state.hasError) {
        context.showSnackBar(
          'Registration failed: ${state.error}',
          Status.error,
        );
      }
    });

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => context.go('/login'),
                padding: EdgeInsets.only(left: 20),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: false,
              floating: false,
              expandedHeight: 0,
            ),
          ],
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/icons/logo_sapa.png',
                            height: 150,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CustomText(
                              text: 'Buat akun baru anda',
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _nameController,
                      labelText: 'Nama',
                      validator: (value) =>
                          ValidationHelper.validateNotEmpty(value, 'Nama'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          ValidationHelper.validateEmail(value),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (value) =>
                          ValidationHelper.validateMultiple(value, [
                            (v) => ValidationHelper.validateNotEmpty(
                              v,
                              'Password',
                            ),
                            (v) => ValidationHelper.validateMinLength(
                              v,
                              8,
                              'Password',
                            ),
                          ]),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _rePasswordController,
                      labelText: 'Ulangi Password',
                      obscureText: _obscure2,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscure2 = !_obscure2),
                      ),
                      validator: (value) =>
                          ValidationHelper.validateMultiple(value, [
                            (v) => ValidationHelper.validateNotEmpty(
                              v,
                              'Ulangi Password',
                            ),
                            (v) => ValidationHelper.validateMinLength(
                              v,
                              8,
                              'Ulangi Password',
                            ),
                            (v) {
                              if (v != _passwordController.text) {
                                return 'Password tidak sama';
                              }
                              return null;
                            },
                          ]),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Buat Akun',
                      isLoading: authState.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          ref
                              .read(authProvider.notifier)
                              .register(
                                _emailController.text,
                                _passwordController.text,
                                _nameController.text,
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () => context.go('/login'),
                        child: RichText(
                          text: TextSpan(
                            text: 'Sudah punya akun? ',
                            style: GoogleFonts.dmSans(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: ' Masuk',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.secondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
