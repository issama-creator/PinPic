// JNI bridge for PinPic deep OCR (PP-OCRv5 + eslav dictionary).
// Adapted from DroidOCR (Apache-2.0).

#include <android/asset_manager_jni.h>
#include <android/bitmap.h>
#include <android/log.h>
#include <jni.h>

#include <sstream>
#include <string>
#include <vector>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

#include "ppocrv5_full.h"

#define TAG "PinPicOCR"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

static PPOCRv5* g_ocr = nullptr;

static std::vector<std::string> load_dict_from_asset(
    AAssetManager* mgr,
    const char* filename) {
  std::vector<std::string> dict;
  AAsset* asset = AAssetManager_open(mgr, filename, AASSET_MODE_BUFFER);
  if (!asset) {
    LOGE("Failed to open dictionary asset: %s", filename);
    return dict;
  }

  const size_t size = static_cast<size_t>(AAsset_getLength(asset));
  std::string buffer(size, '\0');
  AAsset_read(asset, buffer.data(), size);
  AAsset_close(asset);

  std::istringstream iss(buffer);
  std::string line;
  while (std::getline(iss, line)) {
    while (!line.empty() && (line.back() == '\r' || line.back() == '\n')) {
      line.pop_back();
    }
    if (!line.empty()) {
      dict.push_back(line);
    }
  }
  return dict;
}

static std::string objects_to_text(const std::vector<Object>& objects) {
  std::string result;
  for (size_t i = 0; i < objects.size(); i++) {
    const Object& obj = objects[i];
    std::string line;
    for (const Character& ch : obj.text) {
      const std::string& char_str = g_ocr->get_char(ch.id);
      if (char_str.empty()) {
        if (!line.empty() && line.back() != ' ') {
          line += ' ';
        }
        continue;
      }
      line += char_str;
    }
    if (line.empty()) {
      continue;
    }
    if (!result.empty()) {
      result += '\n';
    }
    result += line;
  }
  return result;
}

extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_example_pinpic_ocr_PinpicOcr_nativeLoad(
    JNIEnv* env,
    jobject /* thiz */,
    jobject asset_manager,
    jstring det_param_path,
    jstring det_bin_path,
    jstring rec_param_path,
    jstring rec_bin_path,
    jstring dict_path,
    jboolean use_gpu) {
  if (g_ocr == nullptr) {
    g_ocr = new PPOCRv5();
  }

  AAssetManager* mgr = AAssetManager_fromJava(env, asset_manager);
  if (!mgr) {
    LOGE("Failed to get AssetManager");
    return JNI_FALSE;
  }

  const char* det_param = env->GetStringUTFChars(det_param_path, nullptr);
  const char* det_bin = env->GetStringUTFChars(det_bin_path, nullptr);
  const char* rec_param = env->GetStringUTFChars(rec_param_path, nullptr);
  const char* rec_bin = env->GetStringUTFChars(rec_bin_path, nullptr);
  const char* dict = env->GetStringUTFChars(dict_path, nullptr);

  std::vector<std::string> dictionary = load_dict_from_asset(mgr, dict);
  if (dictionary.empty()) {
    LOGE("Empty OCR dictionary");
    env->ReleaseStringUTFChars(det_param_path, det_param);
    env->ReleaseStringUTFChars(det_bin_path, det_bin);
    env->ReleaseStringUTFChars(rec_param_path, rec_param);
    env->ReleaseStringUTFChars(rec_bin_path, rec_bin);
    env->ReleaseStringUTFChars(dict_path, dict);
    return JNI_FALSE;
  }

  const int ret = g_ocr->load(
      mgr,
      det_param,
      det_bin,
      rec_param,
      rec_bin,
      true,
      use_gpu == JNI_TRUE);
  g_ocr->set_dictionary(dictionary);
  g_ocr->set_target_size(1024);

  env->ReleaseStringUTFChars(det_param_path, det_param);
  env->ReleaseStringUTFChars(det_bin_path, det_bin);
  env->ReleaseStringUTFChars(rec_param_path, rec_param);
  env->ReleaseStringUTFChars(rec_bin_path, rec_bin);
  env->ReleaseStringUTFChars(dict_path, dict);

  if (ret != 0) {
    LOGE("Failed to load PP-OCRv5 models: %d", ret);
    return JNI_FALSE;
  }
  return JNI_TRUE;
}

JNIEXPORT jstring JNICALL
Java_com_example_pinpic_ocr_PinpicOcr_nativeRecognize(
    JNIEnv* env,
    jobject /* thiz */,
    jobject bitmap) {
  if (g_ocr == nullptr) {
    LOGE("OCR model not loaded");
    return env->NewStringUTF("");
  }

  AndroidBitmapInfo info;
  if (AndroidBitmap_getInfo(env, bitmap, &info) != ANDROID_BITMAP_RESULT_SUCCESS) {
    LOGE("AndroidBitmap_getInfo failed");
    return env->NewStringUTF("");
  }
  if (info.format != ANDROID_BITMAP_FORMAT_RGBA_8888) {
    LOGE("Bitmap format is not RGBA_8888");
    return env->NewStringUTF("");
  }

  void* pixels = nullptr;
  if (AndroidBitmap_lockPixels(env, bitmap, &pixels) !=
      ANDROID_BITMAP_RESULT_SUCCESS) {
    LOGE("AndroidBitmap_lockPixels failed");
    return env->NewStringUTF("");
  }

  cv::Mat rgba(
      static_cast<int>(info.height),
      static_cast<int>(info.width),
      CV_8UC4,
      pixels);
  cv::Mat rgb;
  cv::cvtColor(rgba, rgb, cv::COLOR_RGBA2RGB);

  std::vector<Object> objects;
  g_ocr->detect_and_recognize(rgb, objects);
  AndroidBitmap_unlockPixels(env, bitmap);

  const std::string text = objects_to_text(objects);
  return env->NewStringUTF(text.c_str());
}

JNIEXPORT void JNICALL
Java_com_example_pinpic_ocr_PinpicOcr_nativeRelease(
    JNIEnv* /* env */,
    jobject /* thiz */) {
  if (g_ocr != nullptr) {
    delete g_ocr;
    g_ocr = nullptr;
  }
}

}  // extern "C"
