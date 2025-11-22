import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentUrl = '';
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _initializeWebView();
  }

  @override
  void didUpdateWidget(WebViewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the URL has changed, load the new URL
    if (oldWidget.url != widget.url) {
      _currentUrl = widget.url;
      _controller.loadRequest(Uri.parse(_ensureHttps(widget.url)));
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(_ensureHttps(widget.url)));
  }

  String _ensureHttps(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              _controller.loadRequest(Uri.parse(_ensureHttps(widget.url)));
            },
            tooltip: 'Home',
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // URL display
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentUrl,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
              tooltip: 'Back',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  _controller.goForward();
                }
              },
              tooltip: 'Forward',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
