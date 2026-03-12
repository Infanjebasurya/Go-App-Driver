import Flutter
import UIKit

final class NativeImagePickerService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  // Set by AppDelegate so we can present modals.
  var presenter: (() -> UIViewController?)?

  private var pendingResult: FlutterResult?
  private var pendingArgs: [String: Any] = [:]

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pickImage":
      guard pendingResult == nil else {
        result(FlutterError(code: "busy", message: "A picker is already running", details: nil))
        return
      }

      let args = call.arguments as? [String: Any]
      pendingArgs = args ?? [:]

      let source = (args?["source"] as? String) ?? "gallery"
      let picker = UIImagePickerController()
      picker.delegate = self
      picker.allowsEditing = false

      if source == "camera" {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
          result(FlutterError(code: "unavailable", message: "Camera not available", details: nil))
          return
        }
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
      } else {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
          result(FlutterError(code: "unavailable", message: "Photo library not available", details: nil))
          return
        }
        picker.sourceType = .photoLibrary
      }

      guard let vc = presenter?() else {
        result(FlutterError(code: "unavailable", message: "No presenter available", details: nil))
        return
      }

      pendingResult = result
      vc.present(picker, animated: true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    let result = pendingResult
    pendingResult = nil
    pendingArgs = [:]
    picker.dismiss(animated: true) {
      result?(nil)
    }
  }

  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    let result = pendingResult
    let args = pendingArgs
    pendingResult = nil
    pendingArgs = [:]

    picker.dismiss(animated: true) { [weak self] in
      guard let self else {
        result?(FlutterError(code: "unavailable", message: "App not ready", details: nil))
        return
      }

      guard let original = (info[.originalImage] as? UIImage) else {
        result?(nil)
        return
      }

      let imageQuality = (args["imageQuality"] as? NSNumber)?.intValue ?? 100
      let maxWidth = (args["maxWidth"] as? NSNumber)?.doubleValue
      let maxHeight = (args["maxHeight"] as? NSNumber)?.doubleValue

      let scaled = self.scaleIfNeeded(image: original, maxWidth: maxWidth, maxHeight: maxHeight)
      let quality = max(0.0, min(1.0, Double(imageQuality) / 100.0))

      guard let data = scaled.jpegData(compressionQuality: quality) else {
        result?(FlutterError(code: "pick_failed", message: "Failed to encode image", details: nil))
        return
      }

      do {
        let outDir = FileManager.default.temporaryDirectory.appendingPathComponent("picked_images", isDirectory: true)
        try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true, attributes: nil)
        let fileName = "IMG_\(Int(Date().timeIntervalSince1970)).jpg"
        let outUrl = outDir.appendingPathComponent(fileName)
        try data.write(to: outUrl, options: [.atomic])
        result?(["path": outUrl.path, "name": fileName])
      } catch {
        result?(FlutterError(code: "pick_failed", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func scaleIfNeeded(image: UIImage, maxWidth: Double?, maxHeight: Double?) -> UIImage {
    guard let maxWidth, let maxHeight, maxWidth > 0, maxHeight > 0 else { return image }

    let size = image.size
    if size.width <= maxWidth, size.height <= maxHeight { return image }

    let ratio = min(maxWidth / size.width, maxHeight / size.height)
    let target = CGSize(width: floor(size.width * ratio), height: floor(size.height * ratio))

    let renderer = UIGraphicsImageRenderer(size: target)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: target))
    }
  }
}
