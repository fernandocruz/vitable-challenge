import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/auth/presentation/view/otp_verification_page.dart';
import 'package:intl/intl.dart';

class PatientInfoPage extends StatefulWidget {
  const PatientInfoPage({
    required this.onVerified,
    super.key,
  });

  final VoidCallback onVerified;

  @override
  State<PatientInfoPage> createState() =>
      _PatientInfoPageState();
}

class _PatientInfoPageState extends State<PatientInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
        ),
      );
      return;
    }

    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: DateFormat('yyyy-MM-dd')
              .format(_dateOfBirth!),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Information'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'We need your information to '
                  'schedule the appointment.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(AppIcons.person),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Work Email',
                    prefixIcon:
                        Icon(Icons.email_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!v.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Cellphone Number',
                    prefixIcon:
                        Icon(Icons.phone_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Phone is required'
                          : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon:
                          Icon(AppIcons.calendar),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? DateFormat('MMM d, yyyy')
                              .format(_dateOfBirth!)
                          : 'Select date',
                      style: _dateOfBirth == null
                          ? TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final loading = state.status ==
                        AuthStatus.registering;
                    return AppButton(
                      label: loading
                          ? 'Sending OTP...'
                          : 'Continue',
                      onPressed: loading ? null : _submit,
                      isExpanded: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
