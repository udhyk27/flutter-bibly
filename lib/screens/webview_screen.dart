import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {  // PrivacyScreen → WebViewScreen
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();  // _PrivacyScreenState → _WebViewScreenState
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: cs.primary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: tt.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: cs.outline,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: CircularProgressIndicator(color: cs.primary),
              ),
            ),
        ],
      ),
    );
  }
}