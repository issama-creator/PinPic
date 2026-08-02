package com.example.pinpic

import com.example.pinpic.ocr.PinpicOcr
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      CHANNEL,
    ).setMethodCallHandler { call, result ->
      when (call.method) {
        "recognize" -> {
          val path = call.argument<String>("path")
          if (path.isNullOrBlank() || !PinpicOcr.fileExists(path)) {
            result.error("bad_path", "Image path is missing", null)
            return@setMethodCallHandler
          }
          try {
            val aggressive = call.argument<Boolean>("aggressive") ?: true
            val text =
              PinpicOcr.instance.recognizeFile(path, assets, aggressive)
            result.success(text)
          } catch (error: Throwable) {
            result.error("ocr_failed", error.message, null)
          }
        }
        "warmup" -> {
          try {
            result.success(PinpicOcr.instance.ensureLoaded(assets))
          } catch (error: Throwable) {
            result.error("ocr_warmup_failed", error.message, null)
          }
        }
        else -> result.notImplemented()
      }
    }
  }

  override fun onDestroy() {
    PinpicOcr.instance.dispose()
    super.onDestroy()
  }

  companion object {
    private const val CHANNEL = "com.pinpic.app/deep_ocr"
  }
}
