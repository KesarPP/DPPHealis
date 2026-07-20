import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Remove _completeTour and _speakIntro
  content = content.replaceAll(RegExp(r'  Future<void> _completeTour\(\) async \{.*?\n  \}\n\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  Future<void> _speakIntro\(\) async \{.*?\n  \}\n\n', dotAll: true), '');

  // 2. Build method unwrap
  content = content.replaceAll(
    RegExp(r'  @override\n  Widget build\(BuildContext context\) \{.*?\n    return Stack\(\n      children: \[\n        IgnorePointer\(\n          ignoring: _showTourGuide,\n          child: Scaffold\(', dotAll: true),
    '  @override\n  Widget build(BuildContext context) {\n    return Scaffold('
  );

  // 3. Remove overlay and painter at the bottom
  content = content.replaceAll(
    RegExp(r'        \),\n        // Tour Guide Overlay\n        if \(_showTourGuide\) _buildTourGuideOverlay\(context\),\n      \],\n    \);\n  \}\n\n  Widget _buildTourGuideOverlay\(BuildContext context\) \{.*?\nclass SpotlightPainter.*?\n\}\n', dotAll: true),
    '        ),\n    );\n  }\n'
  );

  // 4. Add START button
  final startBtn = '''
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const JourneyMapScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GelatoTheme.purple,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GelatoTheme.purpleDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),''';
  
  content = content.replaceAll('                  const SliverToBoxAdapter(child: SizedBox(height: 100)),', startBtn);

  file.writeAsStringSync(content);
}
