import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  late final WebViewController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('Food WebView Loading: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('Food Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Food Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Food WebView Error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final String baseUrl = Theme.of(context).platform == TargetPlatform.android
          ? 'http://10.0.2.2:8081'
          : 'http://localhost:8081';
      _controller.loadRequest(Uri.parse('$baseUrl/?tab=food&hideNav=true'));
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Tracking')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
