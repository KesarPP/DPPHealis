import 'package:flutter/material.dart';
import 'clinician_dashboard_screen.dart';
import '../data/gelato_theme.dart';
import '../models/coach_profile.dart';
import '../services/auth_service.dart';

class CoachProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;

  const CoachProfileSetupScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<CoachProfileSetupScreen> createState() => _CoachProfileSetupScreenState();
}

class _CoachProfileSetupScreenState extends State<CoachProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taglineController = TextEditingController();
  final _aboutController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _credentialsController = TextEditingController();

  int _selectedAvatarIndex = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _taglineController.dispose();
    _aboutController.dispose();
    _specializationsController.dispose();
    _credentialsController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = AuthService();
      final profile = CoachProfile(
        uid: widget.uid,
        name: widget.name,
        email: widget.email,
        title: _taglineController.text.trim(),
        about: _aboutController.text.trim(),
        specializations: _specializationsController.text.trim()
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        credentials: [
          {
            'title': _credentialsController.text.trim(),
            'subtitle': '',
            'icon': 'verified',
          }
        ],
        localImagePath: 'avatar_$_selectedAvatarIndex',
      );
      await authService.saveCoachProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Setup Completed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ClinicianDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: GelatoTheme.bg,
        appBar: AppBar(
          backgroundColor: GelatoTheme.bg,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Setup Coach Profile',
            style: TextStyle(
              color: GelatoTheme.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Healis!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let\'s customize your public profile that patients see when choosing a coach.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: GelatoTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Avatar selector title
                    const Text(
                      'Select Your Avatar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar Selection Grid/Carousel
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedAvatarIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? GelatoTheme.green.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? GelatoTheme.greenDark : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/images/coaches/coach_${index + 1}.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Option ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      color: isSelected ? GelatoTheme.greenDark : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Inputs Section
                    _buildInputField(
                      label: 'Tag Line',
                      hint: 'e.g. Empowering you to reach your health goals',
                      controller: _taglineController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a tag line' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Credentials and Certifications',
                      hint: 'e.g. RD, CDE, Wellness Coach',
                      controller: _credentialsController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your credentials' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Specializations',
                      hint: 'e.g. Diabetes prevention, weight management, nutrition coaching',
                      controller: _specializationsController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter specializations' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'About Me',
                      hint: 'Share your background, philosophy, and experience...',
                      controller: _aboutController,
                      maxLines: 4,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please tell us about yourself' : null,
                    ),
                    const SizedBox(height: 36),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSaveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GelatoTheme.green,
                          foregroundColor: GelatoTheme.greenDark,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: GelatoTheme.greenDark, strokeWidth: 2),
                              )
                            : const Text(
                                'Save & Complete Setup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: GelatoTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: GelatoTheme.greenDark, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

