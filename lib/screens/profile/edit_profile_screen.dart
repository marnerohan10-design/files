import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().updateProfile(
          name: _name.text,
          phone: _phone.text,
        );
    if (!mounted) return;

    if (error != null) {
      showAppSnackBar(context, error, isError: true);
      return;
    }
    Navigator.pop(context);
    showAppSnackBar(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AuthProvider, bool>((a) => a.isBusy);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _name,
                  label: 'Full name',
                  icon: Icons.person_outline,
                  validator: Validators.fullName,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _email,
                  label: 'Email (cannot be changed)',
                  icon: Icons.mail_outline,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _phone,
                  label: 'Phone (optional)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: Validators.optionalPhone,
                  onSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 28),
                CustomButton(label: 'Save changes', isLoading: busy, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
