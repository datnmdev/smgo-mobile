import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shipgo/core/resources/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

enum GoogleMapMode { view, select }

class GoogleMapsScreen extends StatefulWidget {
  final GoogleMapMode googleMapMode;
  final String? searchQuery;
  final LatLng? pinnedLocation;
  final String title;
  final String pickLocationError;
  final String acceptButtonTitle;

  final Function(LatLng? location, String? placeName) onLocationSelected;

  const GoogleMapsScreen({
    super.key,
    this.searchQuery,
    this.pinnedLocation,
    required this.onLocationSelected,
    this.pickLocationError = 'Vui lòng chọn 1 vị trí trên bản đồ',
    this.googleMapMode = GoogleMapMode.select,
    required this.title,
    this.acceptButtonTitle = 'Xác nhận',
  });

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  late final WebViewController _controller = _createWebViewController();
  bool _isLoading = true;
  bool _locationSelected = false;
  LatLng? _currentPinnedLocation;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _currentPinnedLocation = widget.pinnedLocation;
    _searchQuery = widget.searchQuery;
    _checkAndRequestPermission();
  }

  @override
  void didUpdateWidget(GoogleMapsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      if (oldWidget.searchQuery != widget.searchQuery) {
        _searchQuery = widget.searchQuery;
      }
      if (oldWidget.pinnedLocation?.latitude !=
              widget.pinnedLocation?.latitude ||
          oldWidget.pinnedLocation?.longitude !=
              widget.pinnedLocation?.longitude) {
        _currentPinnedLocation = widget.pinnedLocation;
      }
    });
  }

  WebViewController _createWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    }
    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      final AndroidWebViewController androidController =
          controller.platform as AndroidWebViewController;
      androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          return GeolocationPermissionsResponse(allow: true, retain: true);
        },
      );
    }

    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }

    // Đăng ký kênh giao tiếp nhận tọa độ trực tiếp từ JS của Google Maps web
    controller.addJavaScriptChannel(
      'FlutterMapChannel',
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final data = jsonDecode(message.message);
          final lat = data['lat'];
          final lng = data['lng'];

          if (lat != null && lng != null && !_locationSelected) {
            setState(() {
              _currentPinnedLocation = LatLng(
                (lat as num).toDouble(),
                (lng as num).toDouble(),
              );
            });
          }
        } catch (_) {}
      },
    );

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });

            // Tiêm mã JS để tự động quét tọa độ từ URL/trạng thái bản đồ liên tục
            _controller.runJavaScript('''
              window.open = function(url) {
                if (url) { window.location.href = url; }
                return window;
              };
              window.close = function() {};
              
              document.querySelectorAll('a[target="_blank"]').forEach(function(el) {
                el.removeAttribute('target');
              });

              function removePromoBanner() {
                const banner = document.querySelector('body > div.ml-persistent-promo-banner');
                if (banner) banner.remove();
                const appDiv = document.querySelector('#app');
                if (appDiv) appDiv.style.top = '0px';
              }
              removePromoBanner();

              function hideActionButtons() {
                const buttons = document.querySelectorAll('button, [role="button"], div');
                buttons.forEach(btn => {
                  const text = btn.innerText || btn.textContent || '';
                  if (
                    (text.includes('Đường đi') && text.length < 20) || 
                    (text.includes('Bắt đầu') && text.length < 20) || 
                    (text.includes('Gọi') && text.length < 15)
                  ) {
                    btn.style.display = 'none';
                  }
                });
              }
              hideActionButtons();

              // Theo dõi sự thay đổi URL hoặc trích xuất tọa độ từ chuỗi path '@lat,lng'
              function extractAndSendCoords() {
                const match = window.location.href.match(/!3d([-+]?\\d+(?:\\.\\d+)?)!4d([-+]?\\d+(?:\\.\\d+)?)/);
                if (match && match[1] && match[2]) {
                  const lat = parseFloat(match[1]);
                  const lng = parseFloat(match[2]);
                  if (!isNaN(lat) && !isNaN(lng)) {
                    FlutterMapChannel.postMessage(JSON.stringify({ lat: lat, lng: lng }));
                  }
                }
              }

              // Tự động quét và click "Ở lại web" khi popup Google Maps xuất hiện
              if (!window._stayOnWebInitialized) {
                window._stayOnWebInitialized = true;
                setInterval(extractAndSendCoords, 1000);
                const observer = new MutationObserver((mutations) => {
                  removePromoBanner();
                  hideActionButtons();
                  const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
                  let node;
                  while (node = walker.nextNode()) {
                    if (node.nodeValue && node.nodeValue.trim() === 'Ở lại web') {
                      let parent = node.parentElement;
                      if (parent) {
                        parent.click();
                      }
                    }
                  }
                });
                observer.observe(document.body, { childList: true, subtree: true });
              }

              // Lắng nghe sự kiện click hoặc kéo bản đồ để cập nhật tọa độ liên tục
              if (!window._mapListenerInitialized) {
                window._mapListenerInitialized = true;
                 // Quét mỗi giây
                
                const observer = new MutationObserver(() => {
                  removePromoBanner();
                  hideActionButtons();
                  extractAndSendCoords();
                });
                observer.observe(document.body, { childList: true, subtree: true });
              }
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith('geo:') ||
                url.contains('intent://') ||
                url.contains('market://') ||
                url.contains('whatsapp:')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    return controller;
  }

  Future<void> _checkAndRequestPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
    _loadGoogleMaps();
  }

  void _loadGoogleMaps() {
    late Uri uri;
    if (_currentPinnedLocation != null) {
      final encodedQuery = Uri.encodeComponent(
        '${_currentPinnedLocation!.latitude},${_currentPinnedLocation!.longitude}',
      );
      uri = Uri.parse('https://www.google.com/maps/place/$encodedQuery');
    } else {
      final encodedQuery = Uri.encodeComponent(_searchQuery ?? '');
      uri = Uri.parse('https://www.google.com/maps/search/?q=$encodedQuery');
    }

    _controller.loadRequest(uri);
  }

  void _confirmSelection() {
    if (_currentPinnedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.pickLocationError)));
      return;
    }

    if (_locationSelected) return;
    _locationSelected = true;

    widget.onLocationSelected(_currentPinnedLocation, _searchQuery);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (widget.googleMapMode == GoogleMapMode.select)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                widget.acceptButtonTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
