package com.example.pinpic

import android.content.ContentUris
import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import com.example.pinpic.ocr.PinpicOcr
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class MainActivity : FlutterActivity() {
  /// Single worker: NCNN/g_ocr is not concurrency-safe, and heavy decode must
  /// never block the Android UI thread (ANR during deep indexing).
  private val ocrExecutor =
    Executors.newSingleThreadExecutor { runnable ->
      Thread(runnable, "pinpic-deep-ocr").apply { isDaemon = true }
    }
  private val disposed = AtomicBoolean(false)

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      OCR_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "recognize" -> {
          val path = call.argument<String>("path")
          if (path.isNullOrBlank() || !PinpicOcr.fileExists(path)) {
            result.error("bad_path", "Image path is missing", null)
            return@setMethodCallHandler
          }
          val aggressive = call.argument<Boolean>("aggressive") ?: true
          ocrExecutor.execute {
            if (disposed.get()) {
              result.error("ocr_disposed", "OCR engine disposed", null)
              return@execute
            }
            try {
              val text =
                PinpicOcr.instance.recognizeFile(path, assets, aggressive)
              result.success(text)
            } catch (error: Throwable) {
              result.error("ocr_failed", error.message, null)
            }
          }
        }
        "warmup" -> {
          ocrExecutor.execute {
            if (disposed.get()) {
              result.error("ocr_disposed", "OCR engine disposed", null)
              return@execute
            }
            try {
              result.success(PinpicOcr.instance.ensureLoaded(assets))
            } catch (error: Throwable) {
              result.error("ocr_warmup_failed", error.message, null)
            }
          }
        }
        else -> result.notImplemented()
      }
    }

    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      MEDIA_CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "openInGallery" -> {
          val mediaId = call.argument<String>("mediaId")
          val path = call.argument<String>("path")
          try {
            val opened = openInGallery(mediaId, path)
            result.success(opened)
          } catch (error: Throwable) {
            result.error("open_failed", error.message, null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun openInGallery(mediaId: String?, path: String?): Boolean {
    val uri = resolveViewUri(mediaId, path) ?: return false
    val intent =
      Intent(Intent.ACTION_VIEW).apply {
        setDataAndType(uri, "image/*")
        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }
    if (intent.resolveActivity(packageManager) == null) return false
    startActivity(intent)
    return true
  }

  private fun resolveViewUri(mediaId: String?, path: String?): Uri? {
    val numericId = mediaId?.toLongOrNull()
    if (numericId != null) {
      return ContentUris.withAppendedId(
        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
        numericId,
      )
    }

    if (!path.isNullOrBlank()) {
      val byPath = mediaStoreUriForPath(path)
      if (byPath != null) return byPath

      val file = File(path)
      if (file.isFile) {
        return FileProvider.getUriForFile(
          this,
          "$packageName.fileprovider",
          file,
        )
      }
    }
    return null
  }

  private fun mediaStoreUriForPath(path: String): Uri? {
    val projection = arrayOf(MediaStore.Images.Media._ID)
    contentResolver
      .query(
        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
        projection,
        "${MediaStore.Images.Media.DATA}=?",
        arrayOf(path),
        null,
      )?.use { cursor ->
        if (cursor.moveToFirst()) {
          val id = cursor.getLong(0)
          return ContentUris.withAppendedId(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            id,
          )
        }
      }
    return null
  }

  override fun onDestroy() {
    disposed.set(true)
    ocrExecutor.shutdown()
    PinpicOcr.instance.dispose()
    super.onDestroy()
  }

  companion object {
    private const val OCR_CHANNEL = "com.pinpic.app/deep_ocr"
    private const val MEDIA_CHANNEL = "com.pinpic.app/media"
  }
}
