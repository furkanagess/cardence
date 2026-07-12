import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var savedUserInterfaceStyle: UIUserInterfaceStyle?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    configureAppearanceChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func configureAppearanceChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.cardence/appearance",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setAppearance":
        guard
          let arguments = call.arguments as? [String: Any],
          let brightness = arguments["brightness"] as? String
        else {
          result(FlutterError(
            code: "INVALID_ARGUMENT",
            message: "brightness is required",
            details: nil
          ))
          return
        }
        self?.setAppearance(brightness: brightness)
        result(nil)
      case "resetAppearance":
        self?.resetAppearance()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setAppearance(brightness: String) {
    guard let window else { return }
    if savedUserInterfaceStyle == nil {
      savedUserInterfaceStyle = window.overrideUserInterfaceStyle
    }
    window.overrideUserInterfaceStyle = brightness == "dark" ? .dark : .light
  }

  private func resetAppearance() {
    guard let window else { return }
    window.overrideUserInterfaceStyle = savedUserInterfaceStyle ?? .unspecified
    savedUserInterfaceStyle = nil
  }
}
