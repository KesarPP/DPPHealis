import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/gelato_theme.dart';
import '../models/coach_profile.dart';
import '../services/auth_service.dart';

class CoachProfileScreen extends StatefulWidget {
  final String? coachId;
  const CoachProfileScreen({super.key, this.coachId});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  final _authService = AuthService();
  CoachProfile? _profile;
  bool _isLoading = true;
  bool _isAssignedCoach = false;
  bool _hasPendingRequest = false;
  bool _checkingRequestStatus = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      CoachProfile profile;
      if (widget.coachId != null) {
        profile = await _authService.getCoachProfile(widget.coachId!);
      } else {
        profile = await _authService.getFirstCoachProfile();
      }
      
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
        _checkCoachAssignmentAndRequestStatus();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkCoachAssignmentAndRequestStatus() async {
    final user = AuthService().currentUser;
    if (user == null || _profile == null) {
      if (mounted) {
        setState(() {
          _checkingRequestStatus = false;
        });
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final assignedCoachId = userDoc.data()?['assignedCoachId'] as String?;
      final isAssigned = assignedCoachId == _profile!.uid;

      bool hasPending = false;
      if (isAssigned) {
        final requestDoc = await FirebaseFirestore.instance
            .collection('coach_change_requests')
            .doc('${user.uid}_${_profile!.uid}')
            .get();

        if (requestDoc.exists) {
          final status = requestDoc.data()?['status'] as String?;
          hasPending = status == 'pending';
        }
      }

      if (mounted) {
        setState(() {
          _isAssignedCoach = isAssigned;
          _hasPendingRequest = hasPending;
          _checkingRequestStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking coach change request status: $e');
      if (mounted) {
        setState(() {
          _checkingRequestStatus = false;
        });
      }
    }
  }

  void _showRequestChangeDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.black, width: 2.0),
          ),
          title: const Text(
            'Request Coach Change',
            style: TextStyle(fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please let us know why you would like to request a change of coach:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter reason (optional)...',
                  hintStyle: const TextStyle(fontWeight: FontWeight.w500, color: GelatoTheme.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: GelatoTheme.purpleDark, width: 2.0),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: GelatoTheme.textLight)),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                Navigator.pop(context);
                _submitChangeRequest(reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GelatoTheme.purple,
                foregroundColor: GelatoTheme.textDark,
                side: const BorderSide(color: Colors.black, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitChangeRequest(String reason) async {
    final user = AuthService().currentUser;
    if (user == null || _profile == null) return;

    setState(() {
      _checkingRequestStatus = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] as String? ?? user.displayName ?? 'Anonymous';
      final userEmail = userDoc.data()?['email'] as String? ?? user.email ?? '';

      await FirebaseFirestore.instance
          .collection('coach_change_requests')
          .doc('${user.uid}_${_profile!.uid}')
          .set({
        'userId': user.uid,
        'userName': userName,
        'userEmail': userEmail,
        'currentCoachId': _profile!.uid,
        'currentCoachName': _profile!.name,
        'reason': reason,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coach change request submitted successfully.')),
        );
        setState(() {
          _hasPendingRequest = true;
          _checkingRequestStatus = false;
        });
      }
    } catch (e) {
      debugPrint('Error submitting coach change request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
        setState(() {
          _checkingRequestStatus = false;
        });
      }
    }
  }

  IconData _getCredentialIcon(String iconKey) {
    switch (iconKey) {
      case 'verified':
        return Icons.verified_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'premium':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.workspace_premium_outlined;
    }
  }

  Color _getCredentialColor(int index) {
    final colors = [
      GelatoTheme.blue,
      GelatoTheme.green,
      GelatoTheme.orange,
      GelatoTheme.pink,
      GelatoTheme.purple,
      GelatoTheme.yellow
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: GelatoTheme.textDark),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.purpleDark),
              ),
            )
          : Stack(
              children: [
                // Neo-Brutalist Dotted Background Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 180,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: GelatoTheme.purple,
                      border: Border(
                        bottom: BorderSide(color: Colors.black87, width: 2.0),
                      ),
                    ),
                    child: ClipRect(
                      child: CustomPaint(
                        painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.08)),
                      ),
                    ),
                  ),
                ),

                // Scrollable Profile Content
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20), // Spacing from top of screen

                        // Avatar card
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(color: Colors.black87, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      offset: const Offset(4, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: (_profile?.localImagePath != null && _profile!.localImagePath!.startsWith('avatar_'))
                                      ? Image.asset(
                                          'assets/images/coaches/coach_${(int.tryParse(_profile!.localImagePath!.replaceFirst('avatar_', '')) ?? 0) + 1}.png',
                                          width: 108,
                                          height: 108,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        )
                                      : (_profile?.localImagePath != null && File(_profile!.localImagePath!).existsSync())
                                          ? Image.file(
                                              File(_profile!.localImagePath!),
                                              width: 108,
                                              height: 108,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/clinician_avatar.png',
                                              width: 108,
                                              height: 108,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const CircleAvatar(
                                                radius: 54,
                                                backgroundColor: GelatoTheme.purple,
                                                child: Icon(Icons.person_rounded, size: 54, color: GelatoTheme.textDark),
                                              ),
                                            ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: GelatoTheme.greenBright,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black87, width: 1.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name & Subtitle
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _profile?.name ?? 'Dr. Sarah Mitchell',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded, color: GelatoTheme.purpleDark, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                         Center(
                          child: Text(
                            (_profile?.title == null || _profile!.title.isEmpty)
                                ? 'Senior Health Coach'
                                : _profile!.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: GelatoTheme.textLight,
                              fontWeight: FontWeight.w800,
                              fontStyle: (_profile?.title == null || _profile!.title.isEmpty)
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Cards Group
                        _buildProfileCard(
                          title: 'About',
                          icon: Icons.face_rounded,
                          iconBg: GelatoTheme.purple,
                          child: Text(
                            (_profile?.about == null || _profile!.about.isEmpty)
                                ? 'No bio details available.'
                                : _profile!.about,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GelatoTheme.textDark,
                              height: 1.5,
                              fontStyle: (_profile?.about == null || _profile!.about.isEmpty)
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),

                        _buildProfileCard(
                          title: 'Areas of Expertise',
                          icon: Icons.local_activity_rounded,
                          iconBg: GelatoTheme.yellow,
                          child: (_profile?.specializations == null || _profile!.specializations.isEmpty)
                              ? const Text(
                                  'No specializations listed.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: GelatoTheme.textLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _profile!.specializations
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final idx = entry.key;
                                        final spec = entry.value;
                                        // Map colors dynamically
                                        final colors = [
                                          GelatoTheme.green,
                                          GelatoTheme.yellow,
                                          GelatoTheme.orange,
                                          GelatoTheme.blue,
                                          GelatoTheme.pink,
                                          GelatoTheme.purple
                                        ];
                                        final darkColors = [
                                          GelatoTheme.greenDark,
                                          GelatoTheme.yellowDark,
                                          GelatoTheme.orangeDark,
                                          GelatoTheme.blueDark,
                                          GelatoTheme.pinkDark,
                                          GelatoTheme.purpleDark
                                        ];
                                        return _buildSpecializationChip(
                                          spec,
                                          colors[idx % colors.length],
                                          darkColors[idx % darkColors.length],
                                        );
                                      })
                                      .toList(),
                                ),
                        ),

                        _buildProfileCard(
                          title: 'Credentials & Certifications',
                          icon: Icons.verified_user_rounded,
                          iconBg: GelatoTheme.pink,
                          child: (_profile?.credentials == null || _profile!.credentials.isEmpty)
                              ? const Text(
                                  'No credentials listed.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: GelatoTheme.textLight,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Column(
                                  children: _profile!.credentials.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final cred = entry.value;
                                    return Column(
                                      children: [
                                        if (idx > 0) const Divider(height: 24, color: Colors.black26),
                                        _buildCredentialRow(
                                          icon: _getCredentialIcon(cred['icon'] ?? ''),
                                          title: cred['title'] ?? '',
                                          subtitle: cred['subtitle'] ?? '',
                                          color: _getCredentialColor(idx),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),

                        const SizedBox(height: 8),

                        if (_isAssignedCoach && !_checkingRequestStatus) ...[
                          if (_hasPendingRequest) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: GelatoTheme.yellow,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.black87, width: 2.0),
                                boxShadow: GelatoTheme.cardShadow,
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.hourglass_empty_rounded, color: GelatoTheme.yellowDark),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Change request is pending admin approval.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: GelatoTheme.yellowDark,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            ElevatedButton(
                              onPressed: _showRequestChangeDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GelatoTheme.orange,
                                foregroundColor: GelatoTheme.textDark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Colors.black87, width: 2.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Request Coach Change',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],

                        // Secondary back to chat CTA
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: GelatoTheme.textDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.black87, width: 2.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Back to Chat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required Widget child,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: Icon(icon, color: Colors.black87, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSpecializationChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(1, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black87, width: 1.5),
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: GelatoTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: GelatoTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 12.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 6.0; x <= size.width; x += gridSize) {
      for (double y = 6.0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}
