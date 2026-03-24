import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/auth/presentation/widgets/otp_input_field.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({
    required this.email,
    required this.onVerified,
    super.key,
  });

  final String email;
  final VoidCallback onVerified;

  @override
  State<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState
    extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the 6-digit code'),
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(code);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            widget.onVerified();
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
                Icons.email_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Check your email',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: AppTypography.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We sent a 6-digit code to\n'
                '${widget.email}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color:
                          colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: 200,
                child: OtpInputField(
                  controller: _otpController,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  final loading = state.status ==
                      AuthStatus.verifying;
                  return AppButton(
                    label: loading
                        ? 'Verifying...'
                        : 'Verify',
                    onPressed: loading ? null : _verify,
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
