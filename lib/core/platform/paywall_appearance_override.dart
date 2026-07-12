import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// RevenueCat native paywall'ı uygulama temasına göre açmak için geçici görünüm override'ı.
class PaywallAppearanceOverride {
  PaywallAppearanceOverride._();

  static const _channel = MethodChannel('com.cardence/appearance');

  static Future<void> apply({required bool isDark}) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('setAppearance', {
        'brightness': isDark ? 'dark' : 'light',
      });
    } catch (error) {
      debugPrint('[PaywallAppearanceOverride] apply failed: $error');
    }
  }

  static Future<void> reset() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('resetAppearance');
    } catch (error) {
      debugPrint('[PaywallAppearanceOverride] reset failed: $error');
    }
  }
}
