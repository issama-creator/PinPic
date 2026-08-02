package com.example.pinpic.ocr

import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.Matrix
import android.graphics.Paint
import java.io.File
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

/**
 * Thin JNI wrapper around bundled PP-OCRv5 (eslav) for Russian + Latin text.
 *
 * Adds a light preprocess (upscale + contrast) and, when the first pass looks
 * weak, retries at 90° / 270° — common for phone-shot documents.
 */
class PinpicOcr {
  external fun nativeLoad(
    assetManager: AssetManager,
    detParamPath: String,
    detBinPath: String,
    recParamPath: String,
    recBinPath: String,
    dictPath: String,
    useGpu: Boolean,
  ): Boolean

  external fun nativeRecognize(bitmap: Bitmap): String

  external fun nativeRelease()

  @Volatile private var loaded = false

  fun ensureLoaded(assetManager: AssetManager): Boolean {
    if (loaded) return true
    synchronized(this) {
      if (loaded) return true
      loaded =
        nativeLoad(
          assetManager,
          "pinpic_ocr/det.param",
          "pinpic_ocr/det.bin",
          "pinpic_ocr/rec.param",
          "pinpic_ocr/rec.bin",
          "pinpic_ocr/dict.txt",
          false,
        )
      return loaded
    }
  }

  fun recognizeFile(
    path: String,
    assetManager: AssetManager,
    aggressive: Boolean = true,
  ): String {
    if (!ensureLoaded(assetManager)) return ""
    val options =
      BitmapFactory.Options().apply {
        inPreferredConfig = Bitmap.Config.ARGB_8888
      }
    val decoded = BitmapFactory.decodeFile(path, options) ?: return ""
    val recycleBin = ArrayList<Bitmap>(6)
    recycleBin.add(decoded)

    return try {
      val rgba =
        if (decoded.config == Bitmap.Config.ARGB_8888) {
          decoded
        } else {
          val copy = decoded.copy(Bitmap.Config.ARGB_8888, false) ?: decoded
          if (copy !== decoded) recycleBin.add(copy)
          copy
        }

      val prepared = prepareForOcr(rgba)
      if (prepared !== rgba) recycleBin.add(prepared)

      var best = nativeRecognize(prepared).trim()
      var bestScore = scoreText(best)
      if (!aggressive || bestScore >= GOOD_SCORE) {
        return best
      }

      for (degrees in intArrayOf(90, 270)) {
        val rotated = rotateBitmap(prepared, degrees) ?: continue
        recycleBin.add(rotated)
        val text = nativeRecognize(rotated).trim()
        val score = scoreText(text)
        if (score > bestScore) {
          bestScore = score
          best = text
        }
        if (bestScore >= GOOD_SCORE) break
      }
      best
    } finally {
      for (bitmap in recycleBin) {
        if (!bitmap.isRecycled) bitmap.recycle()
      }
    }
  }

  fun dispose() {
    synchronized(this) {
      if (loaded) {
        nativeRelease()
        loaded = false
      }
    }
  }

  companion object {
    private const val TARGET_MIN_SIDE = 1280
    private const val TARGET_MAX_SIDE = 2400
    private const val GOOD_SCORE = 28

    init {
      System.loadLibrary("pinpic_ocr")
    }

    val instance: PinpicOcr by lazy { PinpicOcr() }

    fun fileExists(path: String): Boolean = File(path).isFile

    fun scoreText(text: String): Int {
      if (text.isEmpty()) return 0
      var letters = 0
      var cyrillic = 0
      var digits = 0
      for (ch in text) {
        when {
          ch in '\u0400'..'\u04FF' -> {
            cyrillic++
            letters++
          }
          ch.isLetter() -> letters++
          ch.isDigit() -> digits++
        }
      }
      return letters + cyrillic * 2 + digits + text.length / 5
    }

    fun prepareForOcr(source: Bitmap): Bitmap {
      var working = source
      var scaled: Bitmap? = null
      val maxSide = max(source.width, source.height)
      val minSide = min(source.width, source.height)

      if (minSide in 1 until TARGET_MIN_SIDE && maxSide < TARGET_MAX_SIDE * 2) {
        val scale =
          min(
            TARGET_MIN_SIDE.toFloat() / minSide.toFloat(),
            TARGET_MAX_SIDE.toFloat() / maxSide.toFloat(),
          )
        if (scale > 1.05f) {
          val w = (source.width * scale).roundToInt().coerceAtLeast(1)
          val h = (source.height * scale).roundToInt().coerceAtLeast(1)
          scaled = Bitmap.createScaledBitmap(source, w, h, true)
          working = scaled
        }
      }

      val enhanced = boostContrast(working)
      if (scaled != null && scaled !== enhanced) {
        scaled.recycle()
      }
      return enhanced
    }

    fun boostContrast(source: Bitmap): Bitmap {
      val out =
        Bitmap.createBitmap(source.width, source.height, Bitmap.Config.ARGB_8888)
      val canvas = Canvas(out)
      val matrix =
        ColorMatrix(
          floatArrayOf(
            1.35f, 0f, 0f, 0f, -24f,
            0f, 1.35f, 0f, 0f, -24f,
            0f, 0f, 1.35f, 0f, -24f,
            0f, 0f, 0f, 1f, 0f,
          ),
        )
      val paint =
        Paint(Paint.FILTER_BITMAP_FLAG).apply {
          colorFilter = ColorMatrixColorFilter(matrix)
        }
      canvas.drawBitmap(source, 0f, 0f, paint)
      return out
    }

    fun rotateBitmap(source: Bitmap, degrees: Int): Bitmap? {
      if (degrees % 360 == 0) return null
      val matrix = Matrix().apply { postRotate(degrees.toFloat()) }
      return Bitmap.createBitmap(
        source,
        0,
        0,
        source.width,
        source.height,
        matrix,
        true,
      )
    }
  }
}
