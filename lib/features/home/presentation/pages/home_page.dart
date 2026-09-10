import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smgo/core/config/app_route_names.dart';
import 'package:smgo/core/network/external_links.dart';
import 'package:smgo/shared/utils/app_url_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WebViewController? _webViewController;
  String? _currentLangCode;
  bool _isLoading = true;

  String _getAssetPath(String langCode) {
    return 'assets/html/home_$langCode.html';
  }

  void _initWebViewController(String langCode) {
    _currentLangCode = langCode;
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted && !_isLoading) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) async {
            try {
              await _injectExternalLinks();
            } finally {
              if (mounted && _isLoading) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            // 1. Điều hướng Route trong App nếu link dạng "smgo://<route_name>"
            if (uri.scheme == 'smgo') {
              _handleAppNavigation(uri);
              return NavigationDecision.prevent;
            }

            // 2. Mở link Web / Social bên ngoài
            if (!request.url.startsWith('file://') &&
                !request.url.startsWith('about:blank')) {
              AppUrlUtils.launchLink(request.url);
              return NavigationDecision.prevent;
            }

            // 3. Cho phép load file HTML Local Asset
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadFlutterAsset(_getAssetPath(langCode));
  }

  // Bắt tên route và điều hướng Native
  void _handleAppNavigation(Uri uri) {
    final routeName = uri.host;
    switch (routeName) {
      case 'upgrade':
        context.pushNamed(AppRouteNames.subscription);
        break;
      default:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLangCode = Localizations.localeOf(context).languageCode;

    if (_webViewController == null) {
      _initWebViewController(newLangCode);
    } else if (_currentLangCode != newLangCode) {
      _currentLangCode = newLangCode;
      _isLoading = true;
      _webViewController?.loadFlutterAsset(_getAssetPath(newLangCode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeData.light().scaffoldBackgroundColor,
      body: SafeArea(
        child: Skeletonizer(
          enabled: _isLoading,
          child: _isLoading
              ? _buildHomeSkeleton()
              : (_webViewController != null
                    ? WebViewWidget(controller: _webViewController!)
                    : const SizedBox.shrink()),
        ),
      ),
    );
  }

  /// Khung Mockup Skeleton dựng mô phỏng đúng bố cục HTML bên trên
  Widget _buildHomeSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Banner
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),

          // Upgrade Card
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),

          // Section Title (Đã bỏ tham số words)
          const Bone.text(width: 140),
          const SizedBox(height: 8),
          const Bone.text(width: 240),
          const SizedBox(height: 16),

          // Grid Features
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Bone.square(size: 36),
                    SizedBox(height: 8),
                    Bone.text(words: 2),
                    SizedBox(height: 4),
                    Bone.text(words: 4),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Full Card
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),

          // Community Card
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _injectExternalLinks() async {
    final controller = _webViewController;
    if (controller == null) return;
    final externalLinksJson = jsonEncode({
      'homepage': ExternalLinks.homepage,
      'termsOfService': ExternalLinks.termsOfService,
      'privacyPolicy': ExternalLinks.privacyPolicy,
      'accountDeletion': ExternalLinks.accountDeletion,
      'facebookGroup': ExternalLinks.facebookGroup,
      'zaloGroup': ExternalLinks.zaloGroup,
      'messengerGroup': ExternalLinks.messengerGroup,
      'guide': ExternalLinks.guide,
    });
    await controller.runJavaScript('''
    if (typeof window.setExternalLinks === 'function') {
      window.setExternalLinks($externalLinksJson);
    }
  ''');
  }
}
