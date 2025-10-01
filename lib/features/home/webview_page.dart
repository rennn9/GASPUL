import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

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

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    // controller animasi untuk gradasi berjalan
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
      Permission.location,
    ].request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: progress < 100
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: const [
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.green,
                            Colors.cyan,
                            Colors.blue,
                            Colors.indigo,
                            Colors.purple,
                            Colors.pink,
                          ],
                          begin: Alignment(
                              -1 + _animationController.value * 2, 0),
                          end: Alignment(1 + _animationController.value * 2, 0),
                          tileMode: TileMode.mirror,
                        ).createShader(bounds);
                      },
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.transparent,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.url),
            ),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue;
                isLoading = progressValue < 100;
              });
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        ],
      ),
    );
  }
}
