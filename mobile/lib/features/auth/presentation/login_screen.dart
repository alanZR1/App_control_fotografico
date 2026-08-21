import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/auth_service.dart';
import '../domain/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.authService,
    this.onAuthenticated,
    super.key,
  });

  final AuthService authService;
  final ValueChanged<UserSession>? onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length < 6) return 'Debe tener al menos 6 caracteres.';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await widget.authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.session != null) {
      widget.onAuthenticated?.call(result.session!);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'No fue posible iniciar sesión.'),
          backgroundColor: AppColors.danger,
        ),
      );
  }

  void _openEmailKeyboard() {
    _emailFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    });
  }

  void _showUnavailable(String title, String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 44,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _BrandHeader(),
                        const SizedBox(height: 24),
                        _LoginCard(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          rememberMe: _rememberMe,
                          obscurePassword: _obscurePassword,
                          isLoading: _isLoading,
                          validateEmail: _validateEmail,
                          validatePassword: _validatePassword,
                          onRememberChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                          onTogglePassword: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onEmailTap: _openEmailKeyboard,
                          onSubmit: _submit,
                          onForgotPassword: () => _showUnavailable(
                            'Recuperar contraseña',
                            'La recuperación por correo estará disponible al conectar el servicio de usuarios.',
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () => _showUnavailable(
                            'Ayuda y soporte',
                            'El canal de soporte se habilitará al conectar los servicios del backend.',
                          ),
                          icon: const Icon(Icons.help_outline_rounded),
                          label: const Text('Ayuda'),
                        ),
                        const Text('¿Necesitas soporte? Contáctanos'),
                      ],
                    ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Control Fotográfico de Obras',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Evidencia y seguimiento de obra',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        Container(
          width: 116,
          height: 116,
          decoration: const BoxDecoration(
            color: AppColors.paleBlue,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.apartment_rounded,
                size: 66,
                color: Color(0xFF91B6F0),
              ),
              Align(
                alignment: const Alignment(0.45, 0.42),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isLoading,
    required this.validateEmail,
    required this.validatePassword,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onEmailTap,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isLoading;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onEmailTap;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A23436F),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const Text(
              'Correo o usuario',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('emailField'),
              controller: emailController,
              focusNode: emailFocusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              autocorrect: false,
              validator: validateEmail,
              onTap: onEmailTap,
              onFieldSubmitted: (_) => passwordFocusNode.requestFocus(),
              decoration: const InputDecoration(
                hintText: 'Ingresa tu correo o usuario',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Contraseña',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: const Key('passwordField'),
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: validatePassword,
              onFieldSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: 'Ingresa tu contraseña',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  key: const Key('togglePassword'),
                  tooltip: obscurePassword
                      ? 'Mostrar contraseña'
                      : 'Ocultar contraseña',
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(value: rememberMe, onChanged: onRememberChanged),
                const Text('Recordarme'),
                const Spacer(),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 58,
              child: FilledButton(
                key: const Key('loginButton'),
                onPressed: isLoading ? null : onSubmit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_outlined, color: AppColors.blue),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Acceso para contratistas, supervisores, beneficiarios y ejecutivos',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
