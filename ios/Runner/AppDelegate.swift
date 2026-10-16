import Flutter
import UIKit
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let channel = FlutterMethodChannel(name: "com.tamankata.app/audio", binaryMessenger: messenger)
      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "playSfx" {
          let args = call.arguments as? [String: Any]
          let type = args?["type"] as? String ?? "ding"
          switch type {
          case "ding", "star", "twinkle":
            AudioServicesPlaySystemSound(1057) // Chime
          case "fanfare":
            AudioServicesPlaySystemSound(1025) // Horn/fanfare
          default:
            AudioServicesPlaySystemSound(1104) // Tap / pop
          }
          result(true)
        } else if call.method == "startBgm" || call.method == "stopBgm" || call.method == "playAsset" {
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
