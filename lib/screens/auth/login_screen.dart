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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordVisible = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue>(authProvider, (_, state) {
      if (state.value != null) {
        context.go('/bottomNav');
      } else if (state.hasError) {
        context.showSnackBar('Login failed: ${state.error}', Status.error);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: SingleChildScrollView(
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
                        CustomText(
                          text: 'SAPA',
                          color: AppColors.primary,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomText(
                            text: 'Masuk ke akun anda',
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
                    controller: _emailController,
                    labelText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => ValidationHelper.validateEmail(value),
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: _passwordVisible,
                    builder: (context, isVisible, child) {
                      return CustomTextFormField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: !isVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => _passwordVisible.value = !isVisible,
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
                      );
                    },
                  ),
                  // const SizedBox(height: 12),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: InkWell(
                  //     onTap: () {},
                  //     child: CustomText(
                  //       text: 'Lupa Password?',
                  //       color: AppColors.secondary,
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'MASUK',
                    isLoading: authState.isLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        ref
                            .read(authProvider.notifier)
                            .login(
                              _emailController.text,
                              _passwordController.text,
                            );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () => context.go('/register'),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: GoogleFonts.dmSans(
                            color: AppColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text: ' Daftar',
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
    );
  }
}
