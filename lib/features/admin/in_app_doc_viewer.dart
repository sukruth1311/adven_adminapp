import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ══════════════════════════════════════════════════════════════════════
//  IN-APP DOCUMENT / IMAGE VIEWER
//  Opens Firebase Storage URLs (PDFs and images) inside the app.
//  • PDFs → WebView with Google Docs viewer (no Chrome redirect)
//  • Images (jpg/png) → full-screen zoomable Image.network
//  • Share button in top bar
//
//  Usage:
//    Navigator.push(context, MaterialPageRoute(
//      builder: (_) => InAppDocViewer(url: url, title: 'Aadhaar'),
//    ));
// ══════════════════════════════════════════════════════════════════════
class InAppDocViewer extends StatefulWidget {
  final String url;
  final String title;
  const InAppDocViewer({super.key, required this.url, required this.title});

  @override
  State<InAppDocViewer> createState() => _InAppDocViewerState();
}

class _InAppDocViewerState extends State<InAppDocViewer> {
  late final WebViewController? _webCtrl;
  bool _isImage = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final url = widget.url.toLowerCase();
    _isImage =
        url.contains('.jpg') ||
        url.contains('.jpeg') ||
        url.contains('.png') ||
        url.contains('.webp') ||
        url.contains('.gif');

    if (!_isImage) {
      // Use Google Docs PDF viewer — works without any native plugin
      final viewerUrl =
          'https://docs.google.com/viewer?embedded=true&url=${Uri.encodeComponent(widget.url)}';
      _webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFF7F9F8))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
          ),
        )
        ..loadRequest(Uri.parse(viewerUrl));
    } else {
      _webCtrl = null;
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              color: Colors.white70,
              size: 20,
            ),
            tooltip: 'Copy link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isImage ? _buildImageViewer() : _buildPdfViewer(),
    );
  }

  Widget _buildImageViewer() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(
        child: Image.network(
          widget.url,
          fit: BoxFit.contain,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
          errorBuilder: (ctx, err, _) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white54,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Could not load image',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return Stack(
      children: [
        WebViewWidget(controller: _webCtrl!),
        if (_loading)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1A6B5A)),
                SizedBox(height: 16),
                Text(
                  'Loading document...',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
