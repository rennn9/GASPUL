import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gaspul/core/services/tts_service.dart';
import 'package:gaspul/core/widgets/gaspul_safe_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = "Web Page",
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  int progress = 0;
  InAppWebViewController? _controller;
  bool _isAppBarVisible = true;
  bool _isHighContrast = false;
  double _textZoom = 1.0;

  late AnimationController _animationController;

  bool _ttsModeActive = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    TTSService().stop();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  void _toggleHighContrast() {
    if (_controller == null) return;
    setState(() {
      _isHighContrast = !_isHighContrast;
    });

    final jsCode = _isHighContrast
        ? "document.documentElement.style.filter = 'invert(1) hue-rotate(180deg)';"
        : "document.documentElement.style.filter = 'invert(0) hue-rotate(0deg)';";

    _controller!.evaluateJavascript(source: jsCode);
  }

  void _increaseTextSize() {
    if (_controller == null) return;
    setState(() {
      _textZoom += 0.1;
    });
    _controller!.evaluateJavascript(
        source: "document.body.style.zoom = '$_textZoom';");
  }

  void _decreaseTextSize() {
    if (_controller == null) return;
    setState(() {
      _textZoom = (_textZoom - 0.1).clamp(0.5, 3.0);
    });
    _controller!.evaluateJavascript(
        source: "document.body.style.zoom = '$_textZoom';");
  }

  void _activateTTSMode() {
    setState(() {
      _ttsModeActive = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mode baca aktif. Ketuk teks/tombol pada halaman."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _injectTapListener() async {
    if (_controller == null) return;
    const jsCode = """
      let startX = 0, startY = 0;
      let startTime = 0;

      document.addEventListener('touchstart', function(e) {
        startX = e.touches[0].clientX;
        startY = e.touches[0].clientY;
        startTime = new Date().getTime();
      }, false);

      document.addEventListener('touchend', function(e) {
        let endX = e.changedTouches[0].clientX;
        let endY = e.changedTouches[0].clientY;
        let endTime = new Date().getTime();

        let deltaX = Math.abs(endX - startX);
        let deltaY = Math.abs(endY - startY);
        let deltaTime = endTime - startTime;

        if (deltaX < 10 && deltaY < 10 && deltaTime < 500) {
          let target = e.target;
          let text = '';
          if (['BUTTON','INPUT','A','SPAN','P','LABEL','DIV'].includes(target.tagName)) {
            text = target.innerText || target.value || target.textContent || '';
          }

          if (text.trim().length > 0 && window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onTapText', text.trim());
          }
        }
      }, false);
    """;

    await _controller!.evaluateJavascript(source: jsCode);
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'high_contrast':
        _toggleHighContrast();
        break;
      case 'zoom_in':
        _increaseTextSize();
        break;
      case 'zoom_out':
        _decreaseTextSize();
        break;
      case 'read_tapped_text':
        _activateTTSMode();
        break;
    }
  }

  Future<void> _openExternalApp(Uri uri) async {
    if (!mounted) return;

    try {
      // ✅ Handle WhatsApp share
      if (uri.scheme == 'whatsapp') {
        final text = uri.queryParameters['text'] ?? '';
        final encodedText = Uri.encodeComponent(text);
        final waUri = Uri.parse("https://wa.me/?text=$encodedText");

        if (await canLaunchUrl(waUri)) {
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("WhatsApp tidak tersedia")),
          );
        }
        return;
      }

      // ✅ Handle Telegram
      if (uri.scheme == 'tg') {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Telegram tidak tersedia")),
          );
        }
        return;
      }

      // ✅ Generic external app
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tidak ada aplikasi untuk membuka: $uri")),
        );
      }
    } catch (e) {
      debugPrint("Error membuka aplikasi eksternal: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GasPulSafeScaffold(
      appBar: _isAppBarVisible
          ? AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _controller?.reload(),
                  tooltip: "Muat ulang halaman",
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  onPressed: _toggleAppBar,
                  tooltip: "Sembunyikan AppBar",
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.accessible),
                  tooltip: "Menu Aksesibilitas",
                  onSelected: _handleMenuSelection,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'high_contrast',
                      child: Row(
                        children: [
                          Icon(
                            _isHighContrast ? Icons.visibility : Icons.contrast,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isHighContrast
                                ? 'Matikan Kontras Tinggi'
                                : 'Mode Kontras Tinggi',
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'zoom_in',
                      child: Row(
                        children: const [
                          Icon(Icons.text_increase),
                          SizedBox(width: 8),
                          Text('Perbesar Teks'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'zoom_out',
                      child: Row(
                        children: const [
                          Icon(Icons.text_decrease),
                          SizedBox(width: 8),
                          Text('Perkecil Teks'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'read_tapped_text',
                      child: Row(
                        children: const [
                          Icon(Icons.volume_up),
                          SizedBox(width: 8),
                          Text('Baca Teks yang Ditekan'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: progress < 100
                    ? LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      )
                    : const SizedBox.shrink(),
              ),
            )
          : null,
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          _controller = controller;

          _controller!.addJavaScriptHandler(
            handlerName: 'onTapText',
            callback: (args) {
              if (args.isNotEmpty && args[0].toString().trim().isNotEmpty) {
                final tappedText = args[0].toString();
                if (_ttsModeActive) {
                  TTSService().speak(tappedText);
                }
              }
            },
          );
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url;
          if (uri == null) return NavigationActionPolicy.ALLOW;

          // Semua skema non-http/https ditangani external app
          if (uri.scheme != 'http' && uri.scheme != 'https') {
            await _openExternalApp(uri);
            return NavigationActionPolicy.CANCEL;
          }

          return NavigationActionPolicy.ALLOW;
        },
        onLoadStop: (controller, url) async {
          await _injectTapListener();
        },
        onProgressChanged: (controller, progressValue) {
          setState(() {
            progress = progressValue;
            isLoading = progressValue < 100;
          });
        },
      ),
      floatingActionButton: !_isAppBarVisible
          ? FloatingActionButton(
              onPressed: _toggleAppBar,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.remove_red_eye,
                color: Colors.black,
              ),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )
          : null,
    );
  }
}
