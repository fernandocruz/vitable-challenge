import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/auth/presentation/view/otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onVerified, super.key});

  final VoidCallback onVerified;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().loginWithOtp(email: email);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.otpSent) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<AuthCubit>(),
                  child: OtpVerificationPage(
                    email: state.email!,
                    onVerified: widget.onVerified,
                  ),
                ),
              ),
            );
          }
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Error'),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.health,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Log in with your work email',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: AppTypography.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              TextFormField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Work Email',
                  prefixIcon:
                      Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final loading = state.status ==
                      AuthStatus.registering;
                  return AppButton(
                    label: loading
                        ? 'Sending OTP...'
                        : 'Send OTP',
                    onPressed: loading ? null : _sendOtp,
                    isExpanded: true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
