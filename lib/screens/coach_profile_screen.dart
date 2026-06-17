import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

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
      body: Stack(
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
                            child: Image.asset(
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
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Dr. Sarah Mitchell',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: GelatoTheme.textDark,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.verified_rounded, color: GelatoTheme.purpleDark, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Senior Health Coach & Nutritionist',
                      style: TextStyle(
                        fontSize: 14,
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Cards Group
                  _buildProfileCard(
                    title: 'About Dr. Mitchell',
                    icon: Icons.face_rounded,
                    iconBg: GelatoTheme.purple,
                    child: const Text(
                      'Dr. Mitchell specializes in preventative health with a focus on chronic disease management. With over 15 years of clinical experience, she empowers patients to master metabolic health using evidence-based nutritional strategies and behavior therapy.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: GelatoTheme.textDark,
                        height: 1.5,
                      ),
                    ),
                  ),

                  _buildProfileCard(
                    title: 'Areas of Expertise',
                    icon: Icons.local_activity_rounded,
                    iconBg: GelatoTheme.yellow,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSpecializationChip('Nutrition', GelatoTheme.green, GelatoTheme.greenDark),
                        _buildSpecializationChip('Behavioral Health', GelatoTheme.yellow, GelatoTheme.yellowDark),
                        _buildSpecializationChip('Metabolic Fitness', GelatoTheme.orange, GelatoTheme.orangeDark),
                        _buildSpecializationChip('Diabetes Prevention', GelatoTheme.blue, GelatoTheme.blueDark),
                      ],
                    ),
                  ),

                  _buildProfileCard(
                    title: 'Credentials & Credentials',
                    icon: Icons.verified_user_rounded,
                    iconBg: GelatoTheme.pink,
                    child: Column(
                      children: [
                        _buildCredentialRow(
                          icon: Icons.verified_outlined,
                          title: 'Board Certified Health Coach',
                          subtitle: 'American Council on Exercise (ACE)',
                          color: GelatoTheme.blue,
                        ),
                        const Divider(height: 24, color: Colors.black26),
                        _buildCredentialRow(
                          icon: Icons.school_outlined,
                          title: 'MS in Clinical Nutrition',
                          subtitle: 'Johns Hopkins University',
                          color: GelatoTheme.green,
                        ),
                        const Divider(height: 24, color: Colors.black26),
                        _buildCredentialRow(
                          icon: Icons.workspace_premium_outlined,
                          title: 'Certified Diabetes Specialist',
                          subtitle: 'ADCES Certification Board',
                          color: GelatoTheme.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Interactive Booking CTA
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(3.5, 3.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showBookingBottomSheet(context),
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      label: const Text(
                        'Book a 1-on-1 Consultation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GelatoTheme.pink,
                        foregroundColor: GelatoTheme.pinkDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

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

  void _showBookingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GelatoTheme.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        side: BorderSide(color: Colors.black87, width: 2.0),
      ),
      builder: (context) {
        final slots = [
          'Thu, Jun 18 at 10:00 AM',
          'Thu, Jun 18 at 2:30 PM',
          'Fri, Jun 19 at 11:00 AM',
          'Fri, Jun 19 at 4:00 PM',
        ];

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: GelatoTheme.purpleDark),
                  SizedBox(width: 8),
                  Text(
                    'Available Consultation Slots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a session time to speak with Dr. Sarah Mitchell directly via video call.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: GelatoTheme.textLight,
                ),
              ),
              const SizedBox(height: 16),
              ...slots.map((slot) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black87, width: 1.5),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        slot,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: GelatoTheme.textDark),
                      onTap: () {
                        Navigator.pop(context);
                        _showSuccessDialog(context, slot);
                      },
                    ),
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: GelatoTheme.cardRadius,
          side: const BorderSide(color: Colors.black, width: 2.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: GelatoTheme.greenBright, size: 28),
            SizedBox(width: 8),
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Your session with Dr. Sarah Mitchell has been scheduled for $slot.\n\nA link to the video room will be sent in your chat before the meeting starts.',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: GelatoTheme.textDark,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Awesome',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: GelatoTheme.purpleDark,
              ),
            ),
          ),
        ],
      ),
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
