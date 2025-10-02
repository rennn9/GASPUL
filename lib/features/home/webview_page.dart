import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';

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
  bool _isDarkMode = false;

  late AnimationController _animationController;

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
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  void _toggleDarkMode() {
    if (_controller == null) return;
    setState(() {
      _isDarkMode = !_isDarkMode;
    });

    final jsCode = _isDarkMode
        ? "document.documentElement.style.filter = 'invert(1) hue-rotate(180deg)';"
        : "document.documentElement.style.filter = 'invert(0) hue-rotate(0deg)';";

    _controller!.evaluateJavascript(source: jsCode);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _isAppBarVisible
          ? AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _controller?.reload(),
                ),
                IconButton(
                  icon: Icon(
                      _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
                  onPressed: _toggleDarkMode,
                ),
                IconButton(
                  icon: const Icon(Icons.remove_red_eye),
                  onPressed: _toggleAppBar,
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
                                end: Alignment(
                                    1 + _animationController.value * 2, 0),
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
            )
          : null,
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) => _controller = controller,
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue;
                isLoading = progressValue < 100;
              });
            },
          ),
          if (isLoading)
            Center(
              child: Lottie.asset(
                'assets/lottie/Speed.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
floatingActionButton: !_isAppBarVisible
    ? FloatingActionButton(
        onPressed: _toggleAppBar,
        backgroundColor: Colors.white, // 🔹 latar putih
        child: const Icon(
          Icons.remove_red_eye,
          color: Colors.black, // 🔹 icon hitam
        ),
        elevation: 6, // 🔹 shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      )
    : null,

    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:lottie/lottie.dart';
// import 'package:gaspul/features/home/widgets/accessibility_provider.dart';
// import 'package:gaspul/features/home/widgets/menu_button.dart';
// import 'package:gaspul/features/home/widgets/accessibility_menu.dart';
// import 'package:gaspul/features/home/home_providers.dart';

// class WebViewPage extends ConsumerStatefulWidget {
//   final String url;
//   final String title;

//   const WebViewPage({
//     super.key,
//     required this.url,
//     this.title = "Web Page",
//   });

//   @override
//   ConsumerState<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends ConsumerState<WebViewPage>
//     with SingleTickerProviderStateMixin {
//   bool isLoading = true;
//   int progress = 0;
//   InAppWebViewController? _controller;
//   bool _isAppBarVisible = true;

//   late AnimationController _animationController;

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();

//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3))
//           ..repeat();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _requestPermissions() async {
//     await [
//       Permission.camera,
//     ].request();
//   }

//   void _toggleAppBar() {
//     setState(() {
//       _isAppBarVisible = !_isAppBarVisible;
//     });
//   }

//   void _applyHighContrast(bool highContrast) {
//     if (_controller == null) return;

//     final jsCode = highContrast
//         ? "document.documentElement.style.filter = 'invert(1) hue-rotate(180deg)';"
//         : "document.documentElement.style.filter = 'invert(0) hue-rotate(0deg)';";

//     _controller!.evaluateJavascript(source: jsCode);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final highContrast = ref.watch(accessibilityProvider).highContrast;
//     final menuOpen = ref.watch(accessibilityMenuProvider);

//     // 🔹 Realtime listen High Contrast
//     ref.listen<AccessibilityState>(accessibilityProvider, (prev, next) {
//       if (next.highContrast != prev?.highContrast) {
//         _applyHighContrast(next.highContrast);
//       }
//     });

//     return Scaffold(
//       appBar: _isAppBarVisible
//           ? AppBar(
//               title: Text(widget.title),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () => _controller?.reload(),
//                 ),
//                 IconButton(
//                   icon: Icon(
//                       _isAppBarVisible ? Icons.remove_red_eye : Icons.remove_red_eye_outlined),
//                   onPressed: _toggleAppBar,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(right: 12),
//                   child: MenuButton(),
//                 ),
//               ],
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(4),
//                 child: progress < 100
//                     ? AnimatedBuilder(
//                         animation: _animationController,
//                         builder: (context, child) {
//                           return ShaderMask(
//                             shaderCallback: (bounds) {
//                               return LinearGradient(
//                                 colors: highContrast
//                                     ? [Colors.white, Colors.white]
//                                     : const [
//                                         Colors.red,
//                                         Colors.orange,
//                                         Colors.yellow,
//                                         Colors.green,
//                                         Colors.cyan,
//                                         Colors.blue,
//                                         Colors.indigo,
//                                         Colors.purple,
//                                         Colors.pink,
//                                       ],
//                                 begin: Alignment(-1 + _animationController.value * 2, 0),
//                                 end: Alignment(1 + _animationController.value * 2, 0),
//                                 tileMode: TileMode.mirror,
//                               ).createShader(bounds);
//                             },
//                             child: LinearProgressIndicator(
//                               value: progress / 100,
//                               backgroundColor: Colors.transparent,
//                               valueColor:
//                                   const AlwaysStoppedAnimation<Color>(Colors.white),
//                               minHeight: 4,
//                             ),
//                           );
//                         },
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             )
//           : null,
//       body: Stack(
//         children: [
//           // 🔹 WebView
//           InAppWebView(
//             initialUrlRequest: URLRequest(
//               url: WebUri(widget.url),
//             ),
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 mediaPlaybackRequiresUserGesture: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 useHybridComposition: true,
//               ),
//             ),
//             onWebViewCreated: (controller) {
//               _controller = controller;
//               _applyHighContrast(highContrast);
//             },
//             onLoadStop: (controller, url) {
//               _applyHighContrast(highContrast);
//             },
//             onProgressChanged: (controller, progressValue) {
//               setState(() {
//                 progress = progressValue;
//                 isLoading = progressValue < 100;
//               });
//             },
//           ),

//           // 🔹 Loading animation
//           if (isLoading)
//             Center(
//               child: Lottie.asset(
//                 'assets/lottie/loading_animation.json',
//                 width: 120,
//                 height: 120,
//                 fit: BoxFit.contain,
//               ),
//             ),

//           // 🔹 AccessibilityMenu popup (paling atas)
//           if (menuOpen)
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: () {
//                   ref.read(accessibilityMenuProvider.notifier).state = false;
//                 },
//                 behavior: HitTestBehavior.translucent,
//                 child: Container(
//                   color: Colors.black38,
//                   child: AccessibilityMenu(
//                     onClose: () {
//                       ref.read(accessibilityMenuProvider.notifier).state = false;
//                     },
//                     top: 0,
//                     right: 10,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: !_isAppBarVisible
//           ? FloatingActionButton(
//               onPressed: _toggleAppBar,
//               child: const Icon(Icons.remove_red_eye),
//             )
//           : null,
//     );
//   }
// }