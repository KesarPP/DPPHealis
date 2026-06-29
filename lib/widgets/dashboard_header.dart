import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/gelato_theme.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';

class StartTourNotification extends Notification {}

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  @override
  void initState() {
    super.initState();
    
    // ECG pulse dot animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    
    String getInitials(String name) {
      if (name.isEmpty) return 'JP';
      final parts = name.trim().split(' ');
      if (parts.length > 1) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    final authService = AuthService();
    final uid = authService.isFirebaseInitialized ? authService.currentUser?.uid : null;

    // Use StreamBuilder so name updates live the moment Firestore is written
    return StreamBuilder<DocumentSnapshot>(
      stream: uid != null
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : null,
      builder: (context, firestoreSnap) {
        // Resolve name: prefer Firestore field, fall back to Firebase Auth displayName
        final firestoreData = firestoreSnap.data?.data() as Map<String, dynamic>?;
        final firestoreName = firestoreData?['name'] as String?;
        final displayName = (firestoreName != null && firestoreName.isNotEmpty)
            ? firestoreName
            : (authService.currentUser?.displayName ?? 'User');
        final firstName = displayName.split(' ').first;
        final initials = getInitials(displayName);

        // Profile image still comes from local storage — use a FutureBuilder just for the image path
        return FutureBuilder<UserProfileData>(
          future: AuthService().getUserProfileData(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data;

            ImageProvider? imageProvider;
            if (profile?.localImagePath != null) {
              imageProvider = FileImage(File(profile!.localImagePath!));
            }

            final String bgName = profile?.profileBgColor ?? 'pink';
            Color avatarBgColor = GelatoTheme.pink;
            Color avatarFgColor = GelatoTheme.pinkDark;

            switch (bgName) {
              case 'pink':
                avatarBgColor = GelatoTheme.pink;
                avatarFgColor = GelatoTheme.pinkDark;
                break;
              case 'green':
                avatarBgColor = GelatoTheme.green;
                avatarFgColor = GelatoTheme.greenDark;
                break;
              case 'yellow':
                avatarBgColor = GelatoTheme.yellow;
                avatarFgColor = GelatoTheme.yellowDark;
                break;
              case 'blue':
                avatarBgColor = GelatoTheme.blue;
                avatarFgColor = GelatoTheme.blueDark;
                break;
              case 'purple':
                avatarBgColor = GelatoTheme.purple;
                avatarFgColor = GelatoTheme.purpleDark;
                break;
              case 'orange':
                avatarBgColor = GelatoTheme.orange;
                avatarFgColor = GelatoTheme.orangeDark;
                break;
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // JP Avatar with Heartbeat ECG Ring
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      ).then((value) {
                        if (value == true) {
                          StartTourNotification().dispatch(context);
                        } else if (mounted) {
                          setState(() {});
                        }
                      });
                    },
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        children: [
                          // Outer circle tracking progress/design
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _AvatarRingPainter(
                                baseColor: avatarBgColor,
                                activeColor: avatarFgColor,
                              ),
                            ),
                          ),
                          // Inner Avatar container
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 19,
                              backgroundColor: avatarBgColor,
                              foregroundImage: imageProvider,
                              onForegroundImageError: imageProvider != null
                                  ? (exception, stackTrace) {
                                      // Silently handle error and fallback to initials
                                    }
                                  : null,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: avatarFgColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                          // Pulse Dot container bottom-right
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulse glow ring
                                  ScaleTransition(
                                    scale: _pulseScale,
                                    child: FadeTransition(
                                      opacity: Tween<double>(begin: 0.8, end: 0.0).animate(_pulseController),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: GelatoTheme.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Inner solid white-ringed green dot
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: GelatoTheme.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Greetings — uses displayName from Firestore StreamBuilder above
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $firstName',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: GelatoTheme.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Your risk score improved again this week.',
                          style: TextStyle(
                            fontSize: 12,
                            color: GelatoTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Menu button
                  IconButton(
                    icon: const Icon(Icons.menu, color: GelatoTheme.textDark, size: 28),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ],
              ),
            );
          },
        ); // end FutureBuilder
      },
    ); // end StreamBuilder
  }
}


class _AvatarRingPainter extends CustomPainter {
  final Color baseColor;
  final Color activeColor;

  _AvatarRingPainter({required this.baseColor, required this.activeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 2.5) / 2;

    // Background circle (Pastel Pink trace)
    final bgPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Active arc (Solid Gelato Purple)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw active portion of the ring
    const startAngle = -math.pi / 2;
    const sweepAngle = 2.2; // about 138 in dasharray
    canvas.drawArc(rect, startAngle, sweepAngle, false, activePaint);
  }

  @override
  bool shouldRepaint(covariant _AvatarRingPainter oldDelegate) =>
      oldDelegate.baseColor != baseColor || oldDelegate.activeColor != activeColor;
}
