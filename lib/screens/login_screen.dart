import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart'; // MainShell

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9), // Soft mint green
                  Color(0xFFE1F5FE), // Very light healthcare blue
                  Color(0xFFFFFFFF),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // Glowing Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00B0FF).withOpacity(0.15), // Healthcare blue glow
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00B0FF).withOpacity(0.2), blurRadius: 120, spreadRadius: 60),
                ]
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF69F0AE).withOpacity(0.15), // Mint green glow
                boxShadow: [
                  BoxShadow(color: const Color(0xFF69F0AE).withOpacity(0.2), blurRadius: 120, spreadRadius: 60),
                ]
              ),
            ),
          ),

          // Floating Images
          const Positioned(
            top: 80,
            left: 20,
            child: _FloatingWidget(
              delaySeconds: 0,
              amplitude: 12,
              child: Image(image: AssetImage('assets/images/3d_apple.png'), width: 90, height: 90),
            ),
          ),
          const Positioned(
            top: 200,
            right: 15,
            child: _FloatingWidget(
              delaySeconds: 1.5,
              amplitude: 15,
              child: Image(image: AssetImage('assets/images/3d_water_droplet.png'), width: 70, height: 70),
            ),
          ),
          const Positioned(
            bottom: 120,
            left: -15,
            child: _FloatingWidget(
              delaySeconds: 0.8,
              amplitude: 10,
              child: Image(image: AssetImage('assets/images/3d_heart.png'), width: 110, height: 110),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Section
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00B0FF).withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      ),
                      child: const Icon(Icons.monitor_heart_rounded, size: 56, color: Color(0xFF00B0FF)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to DPP',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF102A43),
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your diabetes prevention journey.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF627D98),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 48),

                    // Center Section - Frosted Glass Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24.0, sigmaY: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00B0FF).withOpacity(0.08),
                                blurRadius: 40,
                                spreadRadius: -5,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                isPassword: false,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF00B0FF),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Large Login button
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF00B0FF), Color(0xFF00E5FF)], // Bright healthcare blue to bright cyan
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00B0FF).withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: -2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => const MainShell()),
                                    );
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Below Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Color(0xFF627D98), fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Color(0xFF00B0FF), fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_android_rounded, size: 20),
                      label: const Text('Continue with Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF102A43),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, required bool isPassword}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B0FF).withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: Color(0xFF102A43), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF829AB1), fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, color: const Color(0xFF00B0FF)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _FloatingWidget extends StatefulWidget {
  final Widget child;
  final double delaySeconds;
  final double amplitude;

  const _FloatingWidget({required this.child, required this.delaySeconds, required this.amplitude});

  @override
  State<_FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<_FloatingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    Future.delayed(Duration(milliseconds: (widget.delaySeconds * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curvedValue = Curves.easeInOutSine.transform(_controller.value);
        return Transform.translate(
          offset: Offset(0, widget.amplitude * (curvedValue * 2 - 1)),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
