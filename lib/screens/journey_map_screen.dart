import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class JourneyMapScreen extends StatefulWidget {
  const JourneyMapScreen({super.key});

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBCE3F7), // Light blue sky color matching the image edges
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GelatoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '16-Week Journey',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.1,
        maxScale: 4.0,
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Stack(
            children: [
              // Background 3D Image
              Image.asset(
                'assets/images/journey_map_3d.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.sizeOf(context).width,
              ),
              
              // Module 1 (Top Center) - Apartments / Rainbow
              _buildHotspot(
                alignment: const Alignment(0.0, -0.85),
                moduleNumber: 1,
                title: 'Fresh Start',
                color: GelatoTheme.green,
              ),

              // Module 2 (Upper Right) - Classical building
              _buildHotspot(
                alignment: const Alignment(0.5, -0.45),
                moduleNumber: 2,
                title: 'Healthy Eating',
                color: GelatoTheme.yellow,
              ),

              // Module 3 (Middle Left) - Monument / Park
              _buildHotspot(
                alignment: const Alignment(-0.4, -0.05),
                moduleNumber: 3,
                title: 'Active Life',
                color: GelatoTheme.orange,
              ),

              // Module 4 (Lower Right) - Shops / Cars
              _buildHotspot(
                alignment: const Alignment(0.5, 0.35),
                moduleNumber: 4,
                title: 'Daily Balance',
                color: GelatoTheme.blue,
              ),

              // Module 5 (Bottom Left) - Japanese house
              _buildHotspot(
                alignment: const Alignment(-0.4, 0.75),
                moduleNumber: 5,
                title: 'Success Peak',
                color: GelatoTheme.purple,
                isLocked: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHotspot({
    required Alignment alignment,
    required int moduleNumber,
    required String title,
    required Color color,
    bool isLocked = false,
  }) {
    return Positioned.fill(
      child: Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Module $moduleNumber: $title is locked.')),
            );
          } else {
            // Show bottom sheet or navigate
            _showModuleDetails(context, moduleNumber, title, color);
          }
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: isLocked ? 1.0 : 1.0 + (_pulseController.value * 0.05),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Module $moduleNumber',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLocked) ...[
                      const Icon(Icons.lock_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isLocked ? Colors.grey : GelatoTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  void _showModuleDetails(BuildContext context, int module, String title, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Module $module',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to this module! Here you will learn the foundational steps to improve your health journey. Tap the button below to start your lessons.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'START MODULE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
