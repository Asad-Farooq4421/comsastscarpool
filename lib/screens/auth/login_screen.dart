import 'package:flutter/material.dart';

import '../MainScreen.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';

import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // LOGIN FUNCTION
  Future<void> _handleLogin() async {

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // Firebase Login
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _emailController.clear();
      _passwordController.clear();

      // Navigate to Main Screen
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.main,
      );

    } catch (e) {

      if (!mounted) return;

      // Error Message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(

          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 40),

              // TITLE
              Text(
                'Welcome Back!',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: 8),

              Text(
                'Sign in to continue',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // FORM
              Form(
                key: _formKey,

                child: Column(
                  children: [

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                      TextInputType.emailAddress,

                      decoration: const InputDecoration(
                        labelText: 'University Email',
                        hintText:
                        'student@isbstudent.comsats.edu.pk',
                        prefixIcon:
                        Icon(Icons.email),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains(
                            '@isbstudent.comsats.edu.pk')) {
                          return 'Please use your university email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,

                      obscureText:
                      !_isPasswordVisible,

                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText:
                        'Enter your password',

                        prefixIcon:
                        const Icon(Icons.lock),

                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),

                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                              !_isPasswordVisible;
                            });
                          },
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // FORGOT PASSWORD
              Align(
                alignment: Alignment.centerRight,

                child: TextButton(
                  onPressed: () {

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Forgot password feature coming soon',
                        ),
                      ),
                    );
                  },

                  child: Text(
                    'Forgot Password?',

                    style:
                    AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // LOGIN BUTTON
              CustomButton(
                text: 'Login',
                onPressed: _handleLogin,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 20),

              // SIGNUP
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Text(
                    "Don't have an account? ",
                    style:
                    AppTextStyles.bodyMedium,
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signup,
                      );
                    },

                    child: Text(
                      'Sign Up',

                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}