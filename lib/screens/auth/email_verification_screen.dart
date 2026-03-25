import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Simulate sending verification email
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent to your university email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _resendEmail() {
    setState(() {
      _isResending = true;
    });

    // Simulate resending email
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isResending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _verifyEmail() {
    setState(() {
      _isVerifying = true;
    });

    // Simulate email verification
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to profile setup
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, AppRoutes.profile);  // ← Already has this
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We have sent a verification link to your university email address.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Email hint
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'student@isbstudent.comsats.edu.pk',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Verify Button
              CustomButton(
                text: 'I Have Verified My Email',
                onPressed: _verifyEmail,
                isLoading: _isVerifying,
              ),

              const SizedBox(height: 16),

              // Resend link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the email? ",
                    style: AppTextStyles.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _resendEmail,
                    child: Text(
                      'Resend',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Help text
              Text(
                'Check your spam folder if you don\'t see the email in your inbox',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Back to login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: Text(
                  'Back to Login',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}