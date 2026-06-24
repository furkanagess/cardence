import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/config/linkedin_auth_config.dart';

/// LinkedIn OAuth authorization code.
///
/// Önce sistem tarayıcısı (ASWebAuthenticationSession / Chrome Custom Tab) denenir.
/// Plugin henüz native build'e dahil değilse WebView yedek akışına düşer.
Future<String?> requestLinkedInAuthorizationCode(BuildContext context) async {
  try {
    return await _requestWithSystemBrowser();
  } on MissingPluginException {
    if (!context.mounted) {
      return null;
    }
    return _requestWithEmbeddedWebView(context);
  }
}

Future<String?> _requestWithSystemBrowser() async {
  final state = const Uuid().v4();
  final redirectUri = LinkedInAuthConfig.redirectUri;
  final redirect = Uri.parse(redirectUri);

  final authorizationUri = Uri.https(
    'www.linkedin.com',
    '/oauth/v2/authorization',
    <String, String>{
      'response_type': 'code',
      'client_id': LinkedInAuthConfig.clientId,
      'redirect_uri': redirectUri,
      'state': state,
      'scope': 'openid profile email',
      'enable_extended_login': 'true',
    },
  );

  try {
    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authorizationUri.toString(),
      callbackUrlScheme: redirect.scheme,
      options: FlutterWebAuth2Options(
        httpsHost: redirect.host,
        httpsPath: redirect.path,
      ),
    );

    return _parseAuthorizationCode(callbackUrl, expectedState: state);
  } on PlatformException catch (error) {
    if (error.code == 'CANCELED') {
      return null;
    }
    rethrow;
  }
}

Future<String?> _requestWithEmbeddedWebView(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute<String>(
      fullscreenDialog: true,
      builder: (context) => const _LinkedInAuthCodePage(),
    ),
  );
}

String? _parseAuthorizationCode(
  String callbackUrl, {
  required String expectedState,
}) {
  final callback = Uri.parse(callbackUrl);
  if (callback.queryParameters['state'] != expectedState) {
    return null;
  }

  final error = callback.queryParameters['error']?.trim();
  if (error != null && error.isNotEmpty) {
    return null;
  }

  final code = callback.queryParameters['code']?.trim();
  return code != null && code.isNotEmpty ? code : null;
}

class _LinkedInAuthCodePage extends StatefulWidget {
  const _LinkedInAuthCodePage();

  @override
  State<_LinkedInAuthCodePage> createState() => _LinkedInAuthCodePageState();
}

class _LinkedInAuthCodePageState extends State<_LinkedInAuthCodePage> {
  static const _scopes = 'openid profile email';

  late final WebViewController _controller;
  late final String _state;
  bool _isHandlingRedirect = false;

  @override
  void initState() {
    super.initState();
    _state = const Uuid().v4();
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
        'state': _state,
        'scope': _scopes,
        'enable_extended_login': 'true',
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
    if (_isHandlingRedirect || !_isRedirectCallback(url)) {
      return _isHandlingRedirect;
    }

    _isHandlingRedirect = true;
    final code = _parseAuthorizationCode(url, expectedState: _state);

    if (!mounted) {
      return true;
    }

    Navigator.of(context).pop(code);
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
