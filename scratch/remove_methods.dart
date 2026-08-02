import 'dart:io';

void main() {
  final file = File('lib/screens/dashboard_screen.dart');
  final lines = file.readAsLinesSync();
  
  // Lines 147 to 524 inclusive (1-indexed) -> indices 146 to 524 (exclusive)
  lines.removeRange(146, 524);
  
  file.writeAsStringSync(lines.join('\n') + '\n');
}
