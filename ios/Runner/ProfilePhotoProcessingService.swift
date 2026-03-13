import Flutter
import UIKit
import Vision

final class ProfilePhotoProcessingService {
  private static let outWidthPx: Int = 413
  private static let outHeightPx: Int = 531
  private static let aspect: CGFloat = 3.5 / 4.5

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "processCapturedImage":
      guard
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String,
        !path.isEmpty
      else {
        result(FlutterError(code: "invalid_args", message: "path is required", details: nil))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        do {
          let out = try self.process(path: path)
          DispatchQueue.main.async { result(out) }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "process_failed", message: error.localizedDescription, details: nil))
          }
        }
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func process(path: String) throws -> [String: Any] {
    let url = URL(fileURLWithPath: path)
    guard let image = UIImage(contentsOfFile: url.path) else {
      throw NSError(domain: "profile_photo", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"])
    }

    let normalized = image.normalizedOrientation()
    guard let cgImage = normalized.cgImage else {
      throw NSError(domain: "profile_photo", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
    }

    let faceRect = try detectSingleFaceRect(cgImage: cgImage)
    let cropped = try cropHeadAndShoulders(cgImage: cgImage, faceRect: faceRect)
    let resized = resize(cgImage: cropped, widthPx: Self.outWidthPx, heightPx: Self.outHeightPx)

    guard let data = resized.jpegData(compressionQuality: 0.85) else {
      throw NSError(domain: "profile_photo", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to encode image"])
    }

    return [
      "bytes": FlutterStandardTypedData(bytes: data),
      "widthPx": Self.outWidthPx,
      "heightPx": Self.outHeightPx
    ]
  }

  private func detectSingleFaceRect(cgImage: CGImage) throws -> CGRect {
    let request = VNDetectFaceRectanglesRequest()
    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
    try handler.perform([request])

    let faces = request.results as? [VNFaceObservation] ?? []
    if faces.isEmpty {
      throw NSError(domain: "profile_photo", code: 10, userInfo: [NSLocalizedDescriptionKey: "No face detected in captured image."])
    }
    if faces.count > 1 {
      throw NSError(domain: "profile_photo", code: 11, userInfo: [NSLocalizedDescriptionKey: "Multiple faces detected in captured image."])
    }

    // Vision boundingBox is normalized with origin at bottom-left.
    let box = faces[0].boundingBox
    let width = CGFloat(cgImage.width)
    let height = CGFloat(cgImage.height)

    let x = box.origin.x * width
    let y = (1.0 - box.origin.y - box.size.height) * height
    let w = box.size.width * width
    let h = box.size.height * height

    return CGRect(x: x, y: y, width: w, height: h)
  }

  private func cropHeadAndShoulders(cgImage: CGImage, faceRect: CGRect) throws -> CGImage {
    let faceHeight = faceRect.height
    let targetFaceCoverage: CGFloat = 0.75

    let cropHeight = faceHeight / targetFaceCoverage
    let cropWidth = cropHeight * Self.aspect

    let centerX = faceRect.midX
    let centerY = faceRect.midY + faceRect.height * 0.15

    var left = centerX - cropWidth / 2.0
    var top = centerY - cropHeight / 2.0
    var right = centerX + cropWidth / 2.0
    var bottom = centerY + cropHeight / 2.0

    let w = CGFloat(cgImage.width)
    let h = CGFloat(cgImage.height)

    if left < 0 {
      right -= left
      left = 0
    }
    if top < 0 {
      bottom -= top
      top = 0
    }
    if right > w {
      left -= (right - w)
      right = w
    }
    if bottom > h {
      top -= (bottom - h)
      bottom = h
    }

    left = min(max(0, left), w)
    top = min(max(0, top), h)
    right = min(max(0, right), w)
    bottom = min(max(0, bottom), h)

    let cropX = max(0, Int(floor(left)))
    let cropY = max(0, Int(floor(top)))
    let cropW = max(1, min(cgImage.width - cropX, Int(floor(right - left))))
    let cropH = max(1, min(cgImage.height - cropY, Int(floor(bottom - top))))

    let rect = CGRect(x: cropX, y: cropY, width: cropW, height: cropH)
    guard let out = cgImage.cropping(to: rect) else {
      throw NSError(domain: "profile_photo", code: 20, userInfo: [NSLocalizedDescriptionKey: "Failed to crop image"])
    }
    return out
  }

  private func resize(cgImage: CGImage, widthPx: Int, heightPx: Int) -> UIImage {
    let size = CGSize(width: widthPx, height: heightPx)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
      UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: size))
    }
  }
}

private extension UIImage {
  func normalizedOrientation() -> UIImage {
    if imageOrientation == .up { return self }

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1.0
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
  }
}

