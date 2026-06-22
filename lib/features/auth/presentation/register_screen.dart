import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/trainup_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.onGoToLogin});

  final VoidCallback? onGoToLogin;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'aluno';

  static const _roles = [
    ('aluno', 'Aluno', Icons.fitness_center),
    ('personal', 'Personal Trainer', Icons.sports),
    ('admin_academia', 'Admin de Academia', Icons.business),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authFormProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          role: _selectedRole,
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
                const SizedBox(height: 16),
                const Center(
                  child: TrainUpLogo(variant: TrainUpLogoVariant.icon, height: 64),
                ),
                const SizedBox(height: 16),
                Text(
                  'Criar conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Comece sua jornada de treinos.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 32),

                // Nome
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome completo',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Informe seu nome completo.'
                      : null,
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailCtrl,
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
                ),
                const SizedBox(height: 16),

                // Senha
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha.';
                    if (v.length < 6) return 'Mínimo 6 caracteres.';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Perfil
                Text(
                  'Você é:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                ..._roles.map((r) {
                  final (value, label, icon) = r;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _RoleCard(
                      label: label,
                      icon: icon,
                      selected: _selectedRole == value,
                      onTap: () => setState(() => _selectedRole = value),
                    ),
                  );
                }),
                const SizedBox(height: 24),

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
                      : const Text('Criar conta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onGoToLogin,
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        const TextSpan(
                            text: 'Já tem conta? ',
                            style: TextStyle(color: AppColors.grey)),
                        TextSpan(
                          text: 'Entrar',
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.grey.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.green : AppColors.grey, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.navy,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.green, size: 20),
          ],
        ),
      ),
    );
  }
}
