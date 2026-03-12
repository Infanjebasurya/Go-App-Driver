package com.sybrox.goapp_captain.platform.services

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import androidx.exifinterface.media.ExifInterface
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.FaceDetection
import com.google.mlkit.vision.face.FaceDetectorOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import kotlin.math.max
import kotlin.math.min

class ProfilePhotoProcessingService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "processCapturedImage" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrBlank()) {
                    result.error("invalid_args", "path is required", null)
                    return
                }
                Thread {
                    try {
                        val out = process(path)
                        activity.runOnUiThread { result.success(out) }
                    } catch (e: Exception) {
                        activity.runOnUiThread {
                            result.error("process_failed", e.message, null)
                        }
                    }
                }.start()
            }

            else -> result.notImplemented()
        }
    }

    private fun process(path: String): Map<String, Any?> {
        val file = File(path)
        if (!file.exists()) throw IllegalStateException("Image file not found")

        val bitmap = decodeUprightBitmap(file)
        val faceBox = detectSingleFaceBox(bitmap)

        val cropped = cropHeadAndShoulders(bitmap, faceBox)
        val resized = Bitmap.createScaledBitmap(cropped, OUT_W, OUT_H, true)

        val baos = ByteArrayOutputStream()
        resized.compress(Bitmap.CompressFormat.JPEG, 85, baos)
        val bytes = baos.toByteArray()

        return mapOf(
            "bytes" to bytes,
            "widthPx" to OUT_W,
            "heightPx" to OUT_H
        )
    }

    private fun decodeUprightBitmap(file: File): Bitmap {
        val raw = BitmapFactory.decodeFile(file.absolutePath)
            ?: throw IllegalStateException("Failed to decode image")

        val exif = try {
            ExifInterface(file.absolutePath)
        } catch (_: Exception) {
            null
        }
        val orientation = exif?.getAttributeInt(
            ExifInterface.TAG_ORIENTATION,
            ExifInterface.ORIENTATION_NORMAL
        ) ?: ExifInterface.ORIENTATION_NORMAL

        val matrix = android.graphics.Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.preScale(-1f, 1f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.preScale(1f, -1f)
        }

        return if (!matrix.isIdentity) {
            Bitmap.createBitmap(raw, 0, 0, raw.width, raw.height, matrix, true)
        } else {
            raw
        }
    }

    private fun detectSingleFaceBox(bitmap: Bitmap): android.graphics.Rect {
        // Run detection on the already-upright bitmap so the face bounding box coordinates
        // match the bitmap coordinates used for cropping.
        val image = InputImage.fromBitmap(bitmap, 0)

        val detector = FaceDetection.getClient(
            FaceDetectorOptions.Builder()
                .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_ACCURATE)
                .build()
        )

        val faces = Tasks.await(detector.process(image))
        detector.close()

        if (faces.isEmpty()) throw IllegalStateException("No face detected in captured image.")
        if (faces.size > 1) throw IllegalStateException("Multiple faces detected in captured image.")
        return faces[0].boundingBox
    }

    private fun cropHeadAndShoulders(bitmap: Bitmap, faceBox: android.graphics.Rect): Bitmap {
        // Goal: passport-style framing (head fully + shoulders), keep background unchanged.
        // We expand beyond the face bounding box and bias downwards to include shoulders.
        val faceHeight = faceBox.height().toDouble()
        val faceWidth = faceBox.width().toDouble()

        // Face should occupy ~50–60% of the final frame height to include head + shoulders.
        val targetFaceCoverage = 0.52
        var cropHeight = faceHeight / targetFaceCoverage
        var cropWidth = cropHeight * ASPECT

        // Ensure enough horizontal margin (ears/shoulders) even if face box is wide.
        val minCropWidth = faceWidth / 0.62
        if (cropWidth < minCropWidth) {
            cropWidth = minCropWidth
            cropHeight = cropWidth / ASPECT
        }

        val centerX = faceBox.exactCenterX().toDouble()
        // Push the crop center down to reserve more space for shoulders.
        val centerY = (faceBox.exactCenterY() + faceBox.height() * 0.35f).toDouble()

        var left = centerX - cropWidth / 2.0
        var top = centerY - cropHeight / 2.0
        var right = centerX + cropWidth / 2.0
        var bottom = centerY + cropHeight / 2.0

        val w = bitmap.width.toDouble()
        val h = bitmap.height.toDouble()

        if (left < 0) {
            right -= left
            left = 0.0
        }
        if (top < 0) {
            bottom -= top
            top = 0.0
        }
        if (right > w) {
            left -= (right - w)
            right = w
        }
        if (bottom > h) {
            top -= (bottom - h)
            bottom = h
        }

        left = left.coerceIn(0.0, w)
        top = top.coerceIn(0.0, h)
        right = right.coerceIn(0.0, w)
        bottom = bottom.coerceIn(0.0, h)

        val x = max(0, left.toInt())
        val y = max(0, top.toInt())
        val cw = max(1, min(bitmap.width - x, (right - left).toInt()))
        val ch = max(1, min(bitmap.height - y, (bottom - top).toInt()))

        return Bitmap.createBitmap(bitmap, x, y, cw, ch)
    }

    companion object {
        private const val OUT_W = 413
        private const val OUT_H = 531
        private const val ASPECT = 3.5 / 4.5
    }
}
