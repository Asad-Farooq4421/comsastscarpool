import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() =>
      _SignupScreenState();
}

class _SignupScreenState
    extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  final AuthService _authService =
  AuthService();

  bool _isPasswordVisible = false;

  bool _isConfirmPasswordVisible = false;

  bool _isLoading = false;

  String _passwordStrength = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // PASSWORD VALIDATION
  String? _validatePassword(String value) {

    if (value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain a number';
    }

    if (!value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    )) {
      return 'Must contain special character';
    }

    return null;
  }

  // PASSWORD STRENGTH
  void _checkPasswordStrength(
      String password) {

    setState(() {

      if (password.isEmpty) {
        _passwordStrength = '';

      } else if (password.length < 8) {

        _passwordStrength = 'Weak';

      } else if (RegExp(
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
      ).hasMatch(password)) {

        _passwordStrength = 'Strong';

      } else {

        _passwordStrength = 'Medium';
      }
    });
  }

  // SIGNUP
  Future<void> _handleSignup() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      // Firebase Signup
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password:
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate directly to Main Screen
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.main,
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
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

              // BACK BUTTON
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(
                  Icons.arrow_back,
                  size: 24,
                ),

                padding: EdgeInsets.zero,
                alignment:
                Alignment.centerLeft,
              ),

              const SizedBox(height: 20),

              // TITLE
              Text(
                'Create Account',
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: 8),

              Text(
                'Sign up to start sharing rides',

                style:
                AppTextStyles.bodyLarge.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // FORM
              Form(
                key: _formKey,

                child: Column(
                  children: [

                    // NAME
                    TextFormField(
                      controller:
                      _nameController,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'Full Name',

                        hintText:
                        'Enter your full name',

                        prefixIcon:
                        Icon(Icons.person),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your name';
                        }

                        if (value.length < 3) {
                          return 'Name too short';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // EMAIL
                    TextFormField(
                      controller:
                      _emailController,

                      keyboardType:
                      TextInputType
                          .emailAddress,

                      decoration:
                      const InputDecoration(
                        labelText:
                        'University Email',

                        hintText:
                        'student@isbstudent.comsats.edu.pk',

                        prefixIcon:
                        Icon(Icons.email),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.endsWith(
                          '@isbstudent.comsats.edu.pk',
                        )) {
                          return 'Use university email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextFormField(
                      controller:
                      _passwordController,

                      obscureText:
                      !_isPasswordVisible,

                      decoration:
                      InputDecoration(
                        labelText:
                        'Password',

                        hintText:
                        'Create strong password',

                        prefixIcon:
                        const Icon(
                            Icons.lock),

                        suffixIcon:
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons
                                .visibility_off
                                : Icons
                                .visibility,
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
                        return _validatePassword(
                          value ?? '',
                        );
                      },

                      onChanged:
                      _checkPasswordStrength,
                    ),

                    const SizedBox(height: 6),

                    // PASSWORD STRENGTH
                    if (_passwordStrength
                        .isNotEmpty)

                      Row(
                        children: [

                          Text(
                            'Strength: ',
                            style:
                            AppTextStyles
                                .caption,
                          ),

                          Text(
                            _passwordStrength,

                            style:
                            AppTextStyles
                                .caption
                                .copyWith(
                              color:
                              _passwordStrength ==
                                  'Strong'
                                  ? Colors
                                  .green
                                  : _passwordStrength ==
                                  'Medium'
                                  ? Colors
                                  .orange
                                  : Colors
                                  .red,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller:
                      _confirmPasswordController,

                      obscureText:
                      !_isConfirmPasswordVisible,

                      decoration:
                      InputDecoration(
                        labelText:
                        'Confirm Password',

                        hintText:
                        'Confirm password',

                        prefixIcon:
                        const Icon(
                            Icons.lock),

                        suffixIcon:
                        IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons
                                .visibility_off
                                : Icons
                                .visibility,
                          ),

                          onPressed: () {

                            setState(() {
                              _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm password';
                        }

                        if (value !=
                            _passwordController
                                .text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SIGNUP BUTTON
              CustomButton(
                text: 'Sign Up',
                onPressed: _handleSignup,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 20),

              // LOGIN
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Text(
                    'Already have an account? ',
                    style:
                    AppTextStyles.bodyMedium,
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      );
                    },

                    child: Text(
                      'Login',

                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        color:
                        AppColors.primary,

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