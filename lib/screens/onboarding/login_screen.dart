import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final auth = context.read<AuthProvider>();
    final email = await auth.getRememberedEmail();
    if (email != null && mounted) {
      setState(() {
        _emailCtrl.text = email;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    if (_rememberMe) {
      await auth.rememberEmail(_emailCtrl.text.trim());
    } else {
      await auth.clearRememberedEmail();
    }
    final error = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (error != null) {
      setState(() { _error = error; _isLoading = false; });
    } else {
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = AppResponsive.height(context);
    final topH = (screenH * 0.36).clamp(230.0, 310.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        body: Column(
          children: [
            // ── Warm blush hero ───────────────────────────────────────
            SizedBox(
              height: topH + MediaQuery.of(context).padding.top,
              child: Container(
                decoration: const BoxDecoration(gradient: AppGradients.hero),
                child: Stack(
                  children: [
                    // Background circles
                    Positioned(top: -50, right: -30, child: _circle(200, AppColors.primary.withValues(alpha: 0.07))),
                    Positioned(bottom: -20, left: -50, child: _circle(160, AppColors.peach.withValues(alpha: 0.08))),
                    Positioned(top: 80, right: 50, child: _circle(55, AppColors.yellow.withValues(alpha: 0.18))),
                    Positioned(bottom: 50, right: 30, child: _circle(30, AppColors.teal.withValues(alpha: 0.15))),
                    // Dot pattern
                    Positioned(
                      bottom: 30, left: 30,
                      child: _dotPattern(3, 4, AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Camera icon in pink gradient circle
                            Container(
                              width: 82, height: 82,
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 40),
                            ),
                            const SizedBox(height: 18),
                            // Brand name
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(fontFamily: 'Roboto', fontSize: 30, fontWeight: FontWeight.w900),
                                children: [
                                  TextSpan(text: 'Popi', style: TextStyle(color: AppColors.dark)),
                                  TextSpan(text: 'Di', style: TextStyle(color: AppColors.primary)),
                                  TextSpan(text: 'gi', style: TextStyle(color: AppColors.peach)),
                                  TextSpan(text: 'cam', style: TextStyle(color: AppColors.dark)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Your Camera Shop ✨',
                              style: TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Form card ────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back! 👋',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.dark),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to continue shopping',
                        style: TextStyle(fontSize: 14, color: AppColors.textMid),
                      ),
                      const SizedBox(height: 24),

                      // Error banner
                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.red.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),

                      _label('Email'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _emailCtrl,
                        hint: 'your@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscure: !_showPassword,
                        onSubmitted: (_) => _login(),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _showPassword = !_showPassword),
                          child: Icon(
                            _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.inactive,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _rememberMe = !_rememberMe),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: _rememberMe ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _rememberMe ? AppColors.primary : AppColors.inactive,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _rememberMe
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontSize: 13, color: AppColors.textMid),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),

                      // Sign In button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: _isLoading ? null : AppGradients.primary,
                            color: _isLoading ? AppColors.surface : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isLoading ? [] : [
                              BoxShadow(color: AppColors.primary.withValues(alpha: 0.42), blurRadius: 14, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(color: AppColors.textMid, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _dotPattern(int rows, int cols, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (_) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            cols,
            (_) => Container(
              width: 3.5, height: 3.5,
              margin: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEED8E8), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        style: const TextStyle(fontSize: 15, color: AppColors.dark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.inactive),
          prefixIcon: Icon(prefixIcon, color: AppColors.textMid, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}
