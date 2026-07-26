import 'package:flutter/material.dart';
import 'pages/session_timeline_page.dart';
import 'theme/manuscript_theme.dart';

void main() => runApp(const DppApp());

/// Minimal host app for previewing the Session Timeline in isolation.
/// In the real app, navigate to [SessionTimelinePage] from the existing
/// dashboard's "Sessions" entry point instead of using this file.
class DppApp extends StatelessWidget {
  const DppApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Session Timeline Preview',
      theme: ThemeData(
        scaffoldBackgroundColor: ManuscriptColors.parchment,
        useMaterial3: true,
      ),
      home: const SessionTimelinePage(),
    );
  }
}
