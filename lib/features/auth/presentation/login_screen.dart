import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/trainup_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.onGoToRegister});

  final VoidCallback? onGoToRegister;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authFormProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFormProvider);
    final isLoading = authState is AuthFormLoading;

    ref.listen<AuthFormState>(authFormProvider, (_, next) {
      if (next is AuthFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(authFormProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: TrainUpLogo(variant: TrainUpLogoVariant.icon, height: 72),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Entre para continuar seu treino.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 40),
                _EmailField(controller: _emailCtrl),
                const SizedBox(height: 16),
                _PasswordField(
                  controller: _passwordCtrl,
                  obscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Entrar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: widget.onGoToRegister,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                            text: 'Não tem conta? ',
                            style: TextStyle(color: AppColors.grey)),
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'E-mail',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
        if (!v.contains('@')) return 'E-mail inválido.';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Informe a senha.';
        if (v.length < 6) return 'Mínimo 6 caracteres.';
        return null;
      },
    );
  }
}
