import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Remove methods
  content = content.replaceAll(RegExp(r'  Future<void> _completeTour\(\) async \{.*?\n  \}\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  Future<void> _fetchAssignedCoach\(\) async \{.*?\n  \}\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  int _getCoachAvatarIndex\(\) \{.*?\n  \}\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  bool _isFemaleCoach\(\) \{.*?\n  \}\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  Future<void> _speakIntro\(\) async \{.*?\n  \}\n', dotAll: true), '');
  content = content.replaceAll(RegExp(r'  Widget _buildTourGuideOverlay\(\) \{.*?\n  \}\n', dotAll: true), '');
  
  // 2. Remove NotificationListener wrapper
  content = content.replaceAll(RegExp(r'    return NotificationListener<StartTourNotification>\([\s\S]*?child: Scaffold\('), '    return Scaffold(');
  
  // 3. Remove IgnorePointer wrapper
  content = content.replaceAll('              IgnorePointer(\n                ignoring: _showTourGuide && _selectedCoach != null,\n                child: RefreshIndicator(', '              RefreshIndicator(');
  
  // 4. Remove _buildTourGuideOverlay call and adjust closing tags at the end of build method
  content = content.replaceAll('            if (_showTourGuide && _selectedCoach != null)\n              _buildTourGuideOverlay(),\n          ],\n        ),\n        ),\n      ),\n    );\n  }', '          ],\n        ),\n      ),\n    );\n  }');
  
  file.writeAsStringSync(content);
}
