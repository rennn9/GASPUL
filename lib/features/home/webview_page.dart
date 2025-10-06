import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:gaspul/core/services/tts_service.dart';

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
  String _lastTappedText = "";

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
        source: "document.body.style.zoom = '${_textZoom}';");
  }

  void _decreaseTextSize() {
    if (_controller == null) return;
    setState(() {
      _textZoom = (_textZoom - 0.1).clamp(0.5, 3.0);
    });
    _controller!.evaluateJavascript(
        source: "document.body.style.zoom = '${_textZoom}';");
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

        // jika jarak geser kecil dan waktu cukup singkat, dianggap tap
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
                            _isHighContrast
                                ? Icons.visibility
                                : Icons.contrast,
                          ),
                          const SizedBox(width: 8),
                          Text(_isHighContrast
                              ? 'Matikan Kontras Tinggi'
                              : 'Mode Kontras Tinggi'),
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                              minHeight: 4,
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            )
          : null,
      body: SafeArea(
        top: !_isAppBarVisible,
        bottom: false,
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) {
                _controller = controller;

                _controller!.addJavaScriptHandler(
                  handlerName: 'onTapText',
                  callback: (args) {
                    if (args.isNotEmpty &&
                        args[0].toString().trim().isNotEmpty) {
                      String tappedText = args[0].toString();
                      setState(() {
                        _lastTappedText = tappedText;
                      });
                      if (_ttsModeActive) {
                        TTSService().speak(tappedText);
                      }
                    }
                  },
                );
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





// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:lottie/lottie.dart';
// import 'package:gaspul/core/services/tts_service.dart';

// class WebViewPage extends StatefulWidget {
//   final String url;
//   final String title;

//   const WebViewPage({
//     super.key,
//     required this.url,
//     this.title = "Web Page",
//   });

//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage>
//     with SingleTickerProviderStateMixin {
//   bool isLoading = true;
//   int progress = 0;
//   InAppWebViewController? _controller;
//   bool _isAppBarVisible = true;
//   bool _isHighContrast = false;
//   double _textZoom = 1.0;

//   late AnimationController _animationController;
//   String _lastTappedText = ""; // ⬅️ teks terakhir yang diklik user

//   @override
//   void initState() {
//     super.initState();
//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 3))
//           ..repeat();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     TTSService().stop();
//     super.dispose();
//   }

//   void _toggleAppBar() {
//     setState(() {
//       _isAppBarVisible = !_isAppBarVisible;
//     });
//   }

//   void _toggleHighContrast() {
//     if (_controller == null) return;
//     setState(() {
//       _isHighContrast = !_isHighContrast;
//     });

//     final jsCode = _isHighContrast
//         ? "document.documentElement.style.filter = 'invert(1) hue-rotate(180deg)';"
//         : "document.documentElement.style.filter = 'invert(0) hue-rotate(0deg)';";

//     _controller!.evaluateJavascript(source: jsCode);
//   }

//   void _increaseTextSize() {
//     if (_controller == null) return;
//     setState(() {
//       _textZoom += 0.1;
//     });
//     _controller!.evaluateJavascript(
//         source: "document.body.style.zoom = '${_textZoom}';");
//   }

//   void _decreaseTextSize() {
//     if (_controller == null) return;
//     setState(() {
//       _textZoom = (_textZoom - 0.1).clamp(0.5, 3.0);
//     });
//     _controller!.evaluateJavascript(
//         source: "document.body.style.zoom = '${_textZoom}';");
//   }

//   /// 🔸 Baca teks terakhir yang diklik user
//   Future<void> _readLastTappedText() async {
//     if (_lastTappedText.isNotEmpty) {
//       await TTSService().speak(_lastTappedText);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Ketuk teks atau tombol pada halaman terlebih dahulu")),
//       );
//     }
//   }

//   /// 🔸 Pasang listener ke halaman web untuk mendeteksi tap
//   Future<void> _injectTapListener() async {
//     if (_controller == null) return;
//     const jsCode = """
//       document.addEventListener('touchstart', function(e) {
//         let target = e.target;
//         let text = "";

//         // Jika klik elemen tombol/input
//         if (target.tagName === 'BUTTON' || target.tagName === 'INPUT') {
//           text = target.innerText || target.value || "";
//         } else {
//           // Cari teks paling dekat
//           text = target.innerText || target.textContent || "";
//         }

//         // Kirim ke Flutter
//         if (window.flutter_inappwebview) {
//           window.flutter_inappwebview.callHandler('onTapText', text.trim());
//         }
//       }, true);
//     """;

//     await _controller!.evaluateJavascript(source: jsCode);
//   }

//   void _handleMenuSelection(String value) {
//     switch (value) {
//       case 'high_contrast':
//         _toggleHighContrast();
//         break;
//       case 'zoom_in':
//         _increaseTextSize();
//         break;
//       case 'zoom_out':
//         _decreaseTextSize();
//         break;
//       case 'read_tapped_text':
//         _readLastTappedText();
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _isAppBarVisible
//           ? AppBar(
//               title: Text(widget.title),
//               actions: [
//                 // 🔄 Refresh
//                 IconButton(
//                   icon: const Icon(Icons.refresh),
//                   onPressed: () => _controller?.reload(),
//                   tooltip: "Muat ulang halaman",
//                 ),

//                 // 👁️ Sembunyikan AppBar
//                 IconButton(
//                   icon: const Icon(Icons.remove_red_eye),
//                   onPressed: _toggleAppBar,
//                   tooltip: "Sembunyikan AppBar",
//                 ),

//                 // ♿ Menu Aksesibilitas
//                 PopupMenuButton<String>(
//                   icon: const Icon(Icons.accessible),
//                   tooltip: "Menu Aksesibilitas",
//                   onSelected: _handleMenuSelection,
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'high_contrast',
//                       child: Row(
//                         children: [
//                           Icon(
//                             _isHighContrast
//                                 ? Icons.visibility
//                                 : Icons.contrast,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(_isHighContrast
//                               ? 'Matikan Kontras Tinggi'
//                               : 'Mode Kontras Tinggi'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuDivider(),
//                     PopupMenuItem(
//                       value: 'zoom_in',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.text_increase),
//                           SizedBox(width: 8),
//                           Text('Perbesar Teks'),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: 'zoom_out',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.text_decrease),
//                           SizedBox(width: 8),
//                           Text('Perkecil Teks'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuDivider(),
//                     PopupMenuItem(
//                       value: 'read_tapped_text',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.volume_up),
//                           SizedBox(width: 8),
//                           Text('Baca Teks yang Ditekan'),
//                         ],
//                       ),
//                     ),
//                   ],
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
//                                 colors: const [
//                                   Colors.red,
//                                   Colors.orange,
//                                   Colors.yellow,
//                                   Colors.green,
//                                   Colors.cyan,
//                                   Colors.blue,
//                                   Colors.indigo,
//                                   Colors.purple,
//                                   Colors.pink,
//                                 ],
//                                 begin: Alignment(
//                                     -1 + _animationController.value * 2, 0),
//                                 end: Alignment(
//                                     1 + _animationController.value * 2, 0),
//                                 tileMode: TileMode.mirror,
//                               ).createShader(bounds);
//                             },
//                             child: LinearProgressIndicator(
//                               value: progress / 100,
//                               backgroundColor: Colors.transparent,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                   Colors.white),
//                               minHeight: 4,
//                             ),
//                           );
//                         },
//                       )
//                     : const SizedBox.shrink(),
//               ),
//             )
//           : null,
//       body: SafeArea(
//         top: !_isAppBarVisible,
//         bottom: false,
//         child: Stack(
//           children: [
//             InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(widget.url)),
//               onWebViewCreated: (controller) {
//                 _controller = controller;
//                 _controller!.addJavaScriptHandler(
//                   handlerName: 'onTapText',
//                   callback: (args) {
//                     if (args.isNotEmpty && args[0].toString().trim().isNotEmpty) {
//                       setState(() {
//                         _lastTappedText = args[0].toString();
//                       });
//                     }
//                   },
//                 );
//               },
//               onLoadStop: (controller, url) async {
//                 await _injectTapListener();
//               },
//               onProgressChanged: (controller, progressValue) {
//                 setState(() {
//                   progress = progressValue;
//                   isLoading = progressValue < 100;
//                 });
//               },
//             ),
//             if (isLoading)
//               Center(
//                 child: Lottie.asset(
//                   'assets/lottie/Speed.json',
//                   width: 120,
//                   height: 120,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: !_isAppBarVisible
//           ? FloatingActionButton(
//               onPressed: _toggleAppBar,
//               backgroundColor: Colors.white,
//               child: const Icon(
//                 Icons.remove_red_eye,
//                 color: Colors.black,
//               ),
//               elevation: 6,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             )
//           : null,
//     );
//   }
// }



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