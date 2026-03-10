import Flutter
import AVFoundation
import CoreLocation
import GoogleMaps
import Photos
import UIKit
import UserNotifications
import AudioToolbox

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let permissionChannelName = "app/permission_service"
  private let vibrationChannelName = "app/vibration_service"
  private let locationChannelName = "app/location_service"
  private let notificationChannelName = "app/notification_service"
  private let audioChannelName = "app/audio_service"
  private let backgroundChannelName = "app/background_service"
  private let nativeNetworkChannelName = "native_network"
  private let nativeNetworkUpdatesChannelName = "native_network_updates"
  private let nativePermissionsChannelName = "native_permissions"

  private let locationBridge = NativeLocationBridge()
  private let notificationBridge = NativeNotificationBridge()
  private let audioBridge = NativeAudioBridge()
  private let backgroundBridge = NativeBackgroundBridge()
  private let networkBridge = NativeNetworkBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA_EShs05GD76mc2Mjy1l2ByyO2FMHn3yA")
    let didFinish = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      configureNativeChannels(binaryMessenger: controller.binaryMessenger)
    }
    return didFinish
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeServicesBridge") {
      configureNativeChannels(binaryMessenger: registrar.messenger())
    }
  }

  private func configureNativeChannels(binaryMessenger: FlutterBinaryMessenger) {
    let permissionChannel = FlutterMethodChannel(
      name: permissionChannelName,
      binaryMessenger: binaryMessenger
    )
    permissionChannel.setMethodCallHandler { [weak self] call, result in
      self?.handlePermissionCall(call: call, result: result)
    }

    let vibrationChannel = FlutterMethodChannel(
      name: vibrationChannelName,
      binaryMessenger: binaryMessenger
    )
    vibrationChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleVibrationCall(call: call, result: result)
    }

    let locationChannel = FlutterMethodChannel(
      name: locationChannelName,
      binaryMessenger: binaryMessenger
    )
    locationChannel.setMethodCallHandler { [weak self] call, result in
      self?.locationBridge.handle(call: call, result: result)
    }

    let notificationChannel = FlutterMethodChannel(
      name: notificationChannelName,
      binaryMessenger: binaryMessenger
    )
    notificationChannel.setMethodCallHandler { [weak self] call, result in
      self?.notificationBridge.handle(call: call, result: result)
    }

    let audioChannel = FlutterMethodChannel(
      name: audioChannelName,
      binaryMessenger: binaryMessenger
    )
    audioChannel.setMethodCallHandler { [weak self] call, result in
      self?.audioBridge.handle(call: call, result: result)
    }

    let backgroundChannel = FlutterMethodChannel(
      name: backgroundChannelName,
      binaryMessenger: binaryMessenger
    )
    backgroundChannel.setMethodCallHandler { [weak self] call, result in
      self?.backgroundBridge.handle(call: call, result: result)
    }

    let nativeNetworkChannel = FlutterMethodChannel(
      name: nativeNetworkChannelName,
      binaryMessenger: binaryMessenger
    )
    nativeNetworkChannel.setMethodCallHandler { [weak self] call, result in
      self?.networkBridge.handle(call: call, result: result)
    }

    let nativePermissionsChannel = FlutterMethodChannel(
      name: nativePermissionsChannelName,
      binaryMessenger: binaryMessenger
    )
    nativePermissionsChannel.setMethodCallHandler { [weak self] call, result in
      self?.networkBridge.handlePermissions(call: call, result: result)
    }

    let nativeNetworkUpdatesChannel = FlutterEventChannel(
      name: nativeNetworkUpdatesChannelName,
      binaryMessenger: binaryMessenger
    )
    nativeNetworkUpdatesChannel.setStreamHandler(networkBridge)
  }

  private func handlePermissionCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "status":
      guard
        let args = call.arguments as? [String: Any],
        let permission = args["permission"] as? String
      else {
        result(
          FlutterError(code: "invalid_args", message: "permission is required", details: nil)
        )
        return
      }
      permissionStatus(permission: permission, result: result)

    case "request":
      guard
        let args = call.arguments as? [String: Any],
        let permission = args["permission"] as? String
      else {
        result(
          FlutterError(code: "invalid_args", message: "permission is required", details: nil)
        )
        return
      }
      requestPermission(permission: permission, result: result)

    case "openAppSettings":
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(false)
        return
      }
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:]) { success in
          result(success)
        }
      } else {
        result(false)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleVibrationCall(call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "vibrateAlert":
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
      if #available(iOS 13.0, *) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
      }
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func permissionStatus(permission: String, result: @escaping FlutterResult) {
    switch permission {
    case "camera":
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      result(mapCameraStatus(status))

    case "photos":
      if #available(iOS 14, *) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        result(mapPhotoStatus(status))
      } else {
        let status = PHPhotoLibrary.authorizationStatus()
        result(mapLegacyPhotoStatus(status))
      }

    case "notification":
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        result(self.mapNotificationStatus(settings.authorizationStatus))
      }

    default:
      result("restricted")
    }
  }

  private func requestPermission(permission: String, result: @escaping FlutterResult) {
    switch permission {
    case "camera":
      AVCaptureDevice.requestAccess(for: .video) { granted in
        result(granted ? "granted" : self.mapCameraStatus(AVCaptureDevice.authorizationStatus(for: .video)))
      }

    case "photos":
      if #available(iOS 14, *) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
          result(self.mapPhotoStatus(status))
        }
      } else {
        PHPhotoLibrary.requestAuthorization { status in
          result(self.mapLegacyPhotoStatus(status))
        }
      }

    case "notification":
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          result(self.mapNotificationStatus(settings.authorizationStatus))
        }
      }

    default:
      result("restricted")
    }
  }

  private func mapCameraStatus(_ status: AVAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "permanentlyDenied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "denied"
    @unknown default:
      return "denied"
    }
  }

  @available(iOS 14, *)
  private func mapPhotoStatus(_ status: PHAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .limited:
      return "limited"
    case .denied:
      return "permanentlyDenied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "denied"
    @unknown default:
      return "denied"
    }
  }

  private func mapLegacyPhotoStatus(_ status: PHAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .denied:
      return "permanentlyDenied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "denied"
    case .limited:
      return "limited"
    @unknown default:
      return "denied"
    }
  }

  private func mapNotificationStatus(_ status: UNAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "granted"
    case .provisional:
      return "provisional"
    case .ephemeral:
      return "provisional"
    case .denied:
      return "permanentlyDenied"
    case .notDetermined:
      return "denied"
    @unknown default:
      return "denied"
    }
  }
}
