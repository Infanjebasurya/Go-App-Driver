import AVFoundation
import CoreLocation
import Flutter
import Foundation
import Network
import UIKit
import UserNotifications

final class NativeLocationBridge: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var permissionResult: FlutterResult?
  private var locationResult: FlutterResult?
  private var timeoutTimer: Timer?

  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
  }

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkPermission":
      result(mapPermission(CLLocationManager.authorizationStatus()))
    case "requestPermission":
      let currentStatus = CLLocationManager.authorizationStatus()
      if currentStatus != .notDetermined {
        result(mapPermission(currentStatus))
        return
      }
      permissionResult = result
      manager.requestWhenInUseAuthorization()
    case "isLocationServiceEnabled":
      result(CLLocationManager.locationServicesEnabled())
    case "openLocationSettings", "openAppSettings":
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
    case "getLastKnownPosition":
      result(mapLocation(manager.location))
    case "getCurrentPosition":
      let args = call.arguments as? [String: Any]
      let timeLimitMs = (args?["timeLimitMs"] as? Int) ?? 8000
      locationResult = result
      manager.requestLocation()
      timeoutTimer?.invalidate()
      timeoutTimer = Timer.scheduledTimer(withTimeInterval: Double(timeLimitMs) / 1000.0, repeats: false) {
        [weak self] _ in
        guard let self, let locationResult = self.locationResult else { return }
        self.locationResult = nil
        locationResult(self.mapLocation(self.manager.location))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard let permissionResult else { return }
    self.permissionResult = nil
    permissionResult(mapPermission(manager.authorizationStatus))
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    guard let permissionResult else { return }
    self.permissionResult = nil
    permissionResult(mapPermission(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard let locationResult else { return }
    timeoutTimer?.invalidate()
    self.locationResult = nil
    locationResult(
      FlutterError(code: "location_unavailable", message: error.localizedDescription, details: nil)
    )
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locationResult else { return }
    timeoutTimer?.invalidate()
    self.locationResult = nil
    locationResult(mapLocation(locations.last ?? manager.location))
  }

  private func mapPermission(_ status: CLAuthorizationStatus) -> String {
    switch status {
    case .authorizedAlways:
      return "always"
    case .authorizedWhenInUse:
      return "whileInUse"
    case .denied:
      return "deniedForever"
    case .restricted:
      return "unableToDetermine"
    case .notDetermined:
      return "denied"
    @unknown default:
      return "unableToDetermine"
    }
  }

  private func mapLocation(_ location: CLLocation?) -> [String: Double]? {
    guard let location else { return nil }
    return [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
    ]
  }
}

final class NativeNotificationBridge {
  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      result(nil)
    case "show":
      let args = call.arguments as? [String: Any]
      showNotification(
        id: args?["id"] as? Int ?? 1000,
        title: args?["title"] as? String ?? "",
        body: args?["body"] as? String ?? "",
        playSound: true,
        result: result
      )
    case "showProgress":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func showNotification(
    id: Int,
    title: String,
    body: String,
    playSound: Bool,
    result: @escaping FlutterResult
  ) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    if playSound {
      content.sound = .default
    }

    let request = UNNotificationRequest(
      identifier: "goapp_local_\(id)",
      content: content,
      trigger: nil
    )
    UNUserNotificationCenter.current().add(request) { error in
      if let error {
        result(FlutterError(code: "notification_error", message: error.localizedDescription, details: nil))
      } else {
        result(nil)
      }
    }
  }
}

final class NativeAudioBridge: NSObject, AVAudioPlayerDelegate {
  private var player: AVAudioPlayer?

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "playAsset":
      let args = call.arguments as? [String: Any]
      let assetPath = args?["assetPath"] as? String
      let volume = Float(args?["volume"] as? Double ?? 1.0)
      guard let assetPath else {
        result(FlutterError(code: "invalid_args", message: "assetPath is required", details: nil))
        return
      }
      playAsset(assetPath: assetPath, volume: volume, result: result)
    case "stop":
      player?.stop()
      result(nil)
    case "dispose":
      player?.stop()
      player = nil
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func playAsset(assetPath: String, volume: Float, result: @escaping FlutterResult) {
    let normalizedAssetPath = normalizeFlutterAssetPath(assetPath)
    let candidates = [
      "\(Bundle.main.bundlePath)/Frameworks/App.framework/flutter_assets/\(normalizedAssetPath)",
      "\(Bundle.main.resourcePath ?? Bundle.main.bundlePath)/flutter_assets/\(normalizedAssetPath)",
      Bundle.main.path(forResource: normalizedAssetPath, ofType: nil),
    ].compactMap { $0 }

    guard let fullPath = candidates.first(where: { FileManager.default.fileExists(atPath: $0) }) else {
      result(FlutterError(code: "audio_error", message: "Asset not found: \(assetPath)", details: nil))
      return
    }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.duckOthers])
      try session.setActive(true)
      player?.stop()
      player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fullPath))
      player?.volume = volume
      player?.prepareToPlay()
      player?.play()
      result(nil)
    } catch {
      result(FlutterError(code: "audio_error", message: error.localizedDescription, details: nil))
    }
  }

  private func normalizeFlutterAssetPath(_ assetPath: String) -> String {
    if assetPath.hasPrefix("assets/") {
      return assetPath
    }
    return "assets/\(assetPath)"
  }
}

final class NativeBackgroundBridge {
  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "configure":
      result(nil)
    case "isRunning":
      result(false)
    case "startService":
      result(nil)
    case "invoke":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

final class NativeNetworkBridge: NSObject, FlutterStreamHandler {
  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "goapp.native.network")
  private var eventSink: FlutterEventSink?
  private var hasStartedMonitor = false

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isConnected":
      result(isConnected())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func handlePermissions(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "openWifiSettings", "openMobileDataSettings":
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        result(false)
        return
      }
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    if !hasStartedMonitor {
      hasStartedMonitor = true
      monitor.pathUpdateHandler = { [weak self] path in
        self?.eventSink?(path.status == .satisfied)
      }
      monitor.start(queue: queue)
    }
    events(isConnected())
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func isConnected() -> Bool {
    monitor.currentPath.status == .satisfied
  }
}
