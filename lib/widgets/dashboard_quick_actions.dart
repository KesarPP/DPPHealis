import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ActionItem> actions = [
      _ActionItem(
        icon: Icons.restaurant_rounded,
        label: "Log Meal",
        sub: "Snap or type",
        colors: [const Color(0xFF2563EB), const Color(0xFF1D4ED8)], // Meal: Sapphire blue
      ),
      _ActionItem(
        icon: Icons.directions_run_rounded,
        label: "Record Activity",
        sub: "Walk, run, gym",
        colors: [const Color(0xFF10B981), const Color(0xFF0EA5E9)], // Activity: Green to Sky
      ),
      _ActionItem(
        icon: Icons.scale_rounded,
        label: "Update Weight",
        sub: "Last: 78.4 kg",
        colors: [const Color(0xFF7C3AED), const Color(0xFF2563EB)], // Weight: Purple to Blue
      ),
      _ActionItem(
        icon: Icons.straighten_rounded,
        label: "Measure Waist",
        sub: "Last: 98 cm",
        colors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Waist: Amber to Red
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 72,
            ),
            itemBuilder: (context, index) {
              final a = actions[index];
              return _ActionButton(item: a);
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final _ActionItem item;

  const _ActionButton({required this.item});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final a = widget.item;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _scale = 0.96);
      },
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () {
        setState(() => _scale = 1.0);
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: a.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: a.colors[0].withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  a.icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),

              // Labels
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      a.sub,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final String sub;
  final List<Color> colors;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.colors,
  });
}
