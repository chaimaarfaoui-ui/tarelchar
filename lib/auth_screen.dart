import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _friendlyError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    String? dialogError;
    bool dialogLoading = false;
    bool emailSent = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFB8860B), width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recover Your Path',
                      style: TextStyle(
                        color: Color(0xFFB8860B),
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (emailSent) ...[
                      const SizedBox(height: 8),
                      Text(
                        'A reset link has been sent to ${resetEmailController.text.trim()}. Check your inbox.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Color(0xFFB8860B)),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Enter your email and we will send you a link to reset your password.',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: resetEmailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.white38),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFB8860B),
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ),
                      ),
                      if (dialogError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          dialogError!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: dialogLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: dialogLoading
                                ? null
                                : () async {
                                    final resetEmail = resetEmailController.text
                                        .trim();
                                    if (resetEmail.isEmpty) {
                                      setDialogState(() {
                                        dialogError =
                                            'Please enter your email.';
                                      });
                                      return;
                                    }
                                    setDialogState(() {
                                      dialogLoading = true;
                                      dialogError = null;
                                    });
                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                            email: resetEmail,
                                          );
                                      setDialogState(() {
                                        emailSent = true;
                                        dialogLoading = false;
                                      });
                                    } on FirebaseAuthException catch (e) {
                                      setDialogState(() {
                                        dialogError = _friendlyError(e.code);
                                        dialogLoading = false;
                                      });
                                    } catch (e) {
                                      setDialogState(() {
                                        dialogError =
                                            'Something went wrong. Please try again.';
                                        dialogLoading = false;
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8860B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: dialogLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Send Link',
                                    style: TextStyle(color: Colors.black),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('⚗', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 24),
              Text(
                _isLogin ? 'Welcome Back' : 'Enter the Grimoire',
                style: const TextStyle(
                  color: Color(0xFFB8860B),
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? 'Sign in to continue your journey'
                    : 'Create your account to begin',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFB8860B),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFB8860B)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFB8860B),
                      width: 0.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFB8860B)),
                  ),
                ),
              ),
              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8860B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  }),
                  child: Text(
                    _isLogin
                        ? "Don't have an account? Sign Up"
                        : 'Already have an account? Sign In',
                    style: const TextStyle(
                      color: Color(0xFFB8860B),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
