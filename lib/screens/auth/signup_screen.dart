import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/fade_slide_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().signup(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    // Registration done: send the user to login with the email filled in.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
      arguments: _email.text.trim(),
    );
    showAppSnackBar(context, 'Account created. Please log in.');
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AuthProvider, bool>((a) => a.isBusy);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FadeSlideIn(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Create account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      const Text(
                        'Join ShopEase and start shopping',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _name,
                        label: 'Full name',
                        icon: Icons.person_outline,
                        validator: Validators.fullName,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _email,
                        label: 'Email address',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _password,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: Validators.newPassword,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirm,
                        label: 'Confirm password',
                        icon: Icons.lock_reset_outlined,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: Validators.confirmPassword(_password),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(label: 'Create account', isLoading: busy, onPressed: _submit),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?', style: TextStyle(color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: busy ? null : () => Navigator.pop(context),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
