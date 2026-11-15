import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class AuthLoginScreen extends ConsumerStatefulWidget {
  const AuthLoginScreen({super.key});

  @override
  ConsumerState<AuthLoginScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends ConsumerState<AuthLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthLogo(),
            const SizedBox(height: 4),
            const AuthDrinkIllustration(height: 142),
            const SizedBox(height: 2),
            const AuthHeading(
              firstLine: 'Welcome ',
              scriptLine: 'Back!',
              subtitle: 'Your next favorite drink is waiting for you.',
            ),
            const SizedBox(height: 17),
            const AuthFieldLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              key: const Key('login-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _authInputDecoration(
                hint: 'Enter your email address',
                icon: Icons.mail_outline_rounded,
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            const AuthFieldLabel('Password'),
            const SizedBox(height: 6),
            TextFormField(
              key: const Key('login-password'),
              controller: _passwordController,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _authInputDecoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your password.'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/forgot-password'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.coral,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 5),
            AuthPrimaryButton(
              label: 'Log In',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            const AuthDivider(label: 'OR CONTINUE WITH'),
            const SizedBox(height: 12),
            AuthGoogleButton(
              label: 'Continue with Google',
              onPressed: () => _showPrototypeMessage(context),
            ),
            const SizedBox(height: 15),
            AuthBottomLink(
              prompt: "Don't have an account?",
              action: 'Sign Up',
              onTap: () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthRegisterScreen extends ConsumerStatefulWidget {
  const AuthRegisterScreen({super.key});

  @override
  ConsumerState<AuthRegisterScreen> createState() => _AuthRegisterScreenState();
}

class _AuthRegisterScreenState extends ConsumerState<AuthRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms to continue.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthLogo(),
            const SizedBox(height: 1),
            const AuthDrinkIllustration(height: 98, compact: true),
            const SizedBox(height: 1),
            const AuthHeading(
              firstLine: "Let's ",
              scriptLine: 'Get Started!',
              subtitle: 'Create an account and start mixing something amazing.',
              compact: true,
            ),
            const SizedBox(height: 12),
            const AuthFieldLabel('Full Name'),
            const SizedBox(height: 5),
            TextFormField(
              key: const Key('register-name'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _authInputDecoration(
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your name.'
                  : null,
            ),
            const SizedBox(height: 9),
            const AuthFieldLabel('Email Address'),
            const SizedBox(height: 5),
            TextFormField(
              key: const Key('register-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _authInputDecoration(
                hint: 'Enter your email address',
                icon: Icons.mail_outline_rounded,
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 9),
            const AuthFieldLabel('Password'),
            const SizedBox(height: 5),
            TextFormField(
              key: const Key('register-password'),
              controller: _passwordController,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.next,
              decoration: _authInputDecoration(
                hint: 'Create a password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) => value == null || value.length < 6
                  ? 'Use at least 6 characters.'
                  : null,
            ),
            const SizedBox(height: 9),
            const AuthFieldLabel('Confirm Password'),
            const SizedBox(height: 5),
            TextFormField(
              key: const Key('register-confirm-password'),
              obscureText: !_confirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _authInputDecoration(
                hint: 'Confirm your password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  tooltip: _confirmPasswordVisible
                      ? 'Hide password'
                      : 'Show password',
                  onPressed: () => setState(
                    () => _confirmPasswordVisible = !_confirmPasswordVisible,
                  ),
                  icon: Icon(
                    _confirmPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password.';
                }
                return value != _passwordController.text
                    ? 'Passwords do not match.'
                    : null;
              },
            ),
            const SizedBox(height: 6),
            AuthTermsCheckbox(
              value: _acceptedTerms,
              onChanged: (value) =>
                  setState(() => _acceptedTerms = value ?? false),
            ),
            const SizedBox(height: 7),
            AuthPrimaryButton(
              label: 'Create Account',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 10),
            const AuthDivider(label: 'OR SIGN UP WITH'),
            const SizedBox(height: 9),
            AuthGoogleButton(
              label: 'Sign up with Google',
              onPressed: () => _showPrototypeMessage(context),
            ),
            const SizedBox(height: 11),
            AuthBottomLink(
              prompt: 'Already have an account?',
              action: 'Log In',
              onTap: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthForgotPasswordScreen extends ConsumerStatefulWidget {
  const AuthForgotPasswordScreen({super.key});

  @override
  ConsumerState<AuthForgotPasswordScreen> createState() =>
      _AuthForgotPasswordScreenState();
}

class _AuthForgotPasswordScreenState
    extends ConsumerState<AuthForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email: _emailController.text);
      if (!mounted) return;
      setState(
        () => _message =
            'If this email is registered, a reset link will be sent.',
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      if (error.code == 'user-not-found') {
        setState(
          () => _message =
              'If this email is registered, a reset link will be sent.',
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back to login',
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back_rounded),
                color: AppColors.navy,
              ),
            ),
            const AuthLogo(),
            const SizedBox(height: 12),
            const AuthDrinkIllustration(height: 188, showEnvelope: true),
            const SizedBox(height: 8),
            const AuthHeading(
              firstLine: 'Forgot ',
              scriptLine: 'Password?',
              subtitle: "No worries! Enter your email and we'll help you reset your password.",
            ),
            const SizedBox(height: 24),
            const AuthFieldLabel('Email Address'),
            const SizedBox(height: 6),
            TextFormField(
              key: const Key('forgot-email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: _authInputDecoration(
                hint: 'Enter your email address',
                icon: Icons.mail_outline_rounded,
              ),
              validator: _validateEmail,
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              AuthStatusMessage(message: _message!, success: true),
            ],
            const SizedBox(height: 18),
            AuthPrimaryButton(
              label: 'Send Reset Link',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(foregroundColor: AppColors.coral),
              child: const Text(
                'Back to Login',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pastelPink,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned(
                  left: 12,
                  top: 52,
                  child: _FruitDecoration(emoji: '🍊', size: 30, angle: -0.3),
                ),
                const Positioned(
                  right: 12,
                  top: 134,
                  child: _FruitDecoration(emoji: '🍓', size: 28, angle: 0.2),
                ),
                const Positioned(
                  left: 15,
                  bottom: 112,
                  child: _FruitDecoration(emoji: '🍋', size: 27, angle: 0.2),
                ),
                const Positioned(
                  right: 14,
                  bottom: 46,
                  child: _FruitDecoration(emoji: '🌿', size: 28, angle: -0.2),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 393),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 12,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 24,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.navy.withValues(alpha: 0.08),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                23,
                                16,
                                23,
                                18,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'home',
              style: TextStyle(color: AppColors.navy),
            ),
            TextSpan(
              text: 'mix',
              style: TextStyle(color: AppColors.coral),
            ),
          ],
        ),
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.2,
        ),
      ),
    );
  }
}

class AuthHeading extends StatelessWidget {
  const AuthHeading({
    required this.firstLine,
    required this.scriptLine,
    required this.subtitle,
    this.compact = false,
    super.key,
  });

  final String firstLine;
  final String scriptLine;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: firstLine),
              TextSpan(
                text: scriptLine,
                style: TextStyle(
                  color: AppColors.coral,
                  fontFamily: 'WindSong',
                  fontWeight: FontWeight.w500,
                  fontSize: compact ? 31 : 35,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.navy,
            fontSize: compact ? 23 : 25,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: compact ? 3 : 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class AuthDrinkIllustration extends StatelessWidget {
  const AuthDrinkIllustration({
    required this.height,
    this.compact = false,
    this.showEnvelope = false,
    super.key,
  });

  final double height;
  final bool compact;
  final bool showEnvelope;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 13,
            child: Container(
              width: compact ? 142 : 176,
              height: compact ? 32 : 39,
              decoration: BoxDecoration(
                color: AppColors.lemon.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Image.asset(
            'assets/images/onboarding_cocktail.png',
            width: compact ? 132 : height * 0.98,
            height: height,
            fit: BoxFit.contain,
            semanticLabel: 'Illustrated pink fruit cocktail',
          ),
          Positioned(
            left: compact ? 43 : 54,
            top: 20,
            child: const _FruitDecoration(emoji: '🍓', size: 20, angle: -0.2),
          ),
          Positioned(
            right: compact ? 45 : 55,
            top: 8,
            child: const _FruitDecoration(emoji: '🍋', size: 22, angle: 0.15),
          ),
          if (showEnvelope)
            Positioned(
              right: 50,
              bottom: 33,
              child: Container(
                width: 43,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mail_rounded,
                  color: AppColors.coral,
                  size: 23,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.7),
          elevation: 3,
          shadowColor: AppColors.navy.withValues(alpha: 0.18),
          shape: const StadiumBorder(),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
      ),
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          backgroundColor: AppColors.white,
          side: const BorderSide(color: Color(0xFFEDE8E6)),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE7DDD8), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE7DDD8), height: 1)),
      ],
    );
  }
}

class AuthBottomLink extends StatelessWidget {
  const AuthBottomLink({
    required this.prompt,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(
          '$prompt ',
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.coral,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthTermsCheckbox extends StatelessWidget {
  const AuthTermsCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 28,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!value),
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.coral,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({
    required this.message,
    required this.success,
    super.key,
  });

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.green : AppColors.coral;
    return Row(
      children: [
        Icon(
          success ? Icons.check_circle_outline : Icons.error_outline,
          color: color,
          size: 17,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: success ? AppColors.navy : color,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _FruitDecoration extends StatelessWidget {
  const _FruitDecoration({
    required this.emoji,
    required this.size,
    required this.angle,
  });

  final String emoji;
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Text(emoji, style: TextStyle(fontSize: size)),
    );
  }
}

InputDecoration _authInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 19, color: AppColors.coral),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.white,
    hintStyle: const TextStyle(color: Color(0xFF9A9695), fontSize: 11),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    prefixIconConstraints: const BoxConstraints(minWidth: 41),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFF0E8E3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.coral, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFD95B68), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFD95B68), width: 1.4),
    ),
  );
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Please enter your email address.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Please enter a valid email address.';
  }
  return null;
}

void _showPrototypeMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Google authentication will be connected later.'),
    ),
  );
}
