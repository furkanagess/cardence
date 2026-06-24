import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/linkedin_auth_config.dart';

Future<String?> requestLinkedInAuthorizationCode(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      fullscreenDialog: true,
      builder: (context) => const _LinkedInAuthCodePage(),
    ),
  );
}

class _LinkedInAuthCodePage extends StatefulWidget {
  const _LinkedInAuthCodePage();

  @override
  State<_LinkedInAuthCodePage> createState() => _LinkedInAuthCodePageState();
}

class _LinkedInAuthCodePageState extends State<_LinkedInAuthCodePage> {
  static const _scopes = 'openid profile email';

  late final WebViewController _controller;
  bool _isHandlingRedirect = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
          onPageFinished: _handlePageFinished,
        ),
      )
      ..loadRequest(_buildAuthorizationUri());
  }

  Uri _buildAuthorizationUri() {
    return Uri.https(
      'www.linkedin.com',
      '/oauth/v2/authorization',
      <String, String>{
        'response_type': 'code',
        'client_id': LinkedInAuthConfig.clientId,
        'redirect_uri': LinkedInAuthConfig.redirectUri,
        'state': const Uuid().v4(),
        'scope': _scopes,
      },
    );
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    if (_tryCompleteFromUrl(request.url)) {
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _handlePageFinished(String url) {
    _tryCompleteFromUrl(url);
  }

  bool _tryCompleteFromUrl(String url) {
    if (_isHandlingRedirect) {
      return true;
    }

    if (!_isRedirectCallback(url)) {
      return false;
    }

    final code = Uri.tryParse(url)?.queryParameters['code']?.trim();
    _isHandlingRedirect = true;

    if (!mounted) {
      return true;
    }

    Navigator.of(context).pop(code != null && code.isNotEmpty ? code : null);
    return true;
  }

  bool _isRedirectCallback(String url) {
    final target = Uri.parse(LinkedInAuthConfig.redirectUri);
    final current = Uri.tryParse(url);
    if (current == null) {
      return false;
    }

    return current.scheme == target.scheme &&
        current.host == target.host &&
        current.path == target.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LinkedIn ile giriş'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
