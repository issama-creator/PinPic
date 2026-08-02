cmake_minimum_required(VERSION 3.22.1)

project(pinpic_ocr)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(NCNN_DIR ${CMAKE_SOURCE_DIR}/../jniLibs/ncnn)
set(OpenCV_DIR ${CMAKE_SOURCE_DIR}/../jniLibs/opencv-mobile/sdk/native/jni)

if(NOT EXISTS ${NCNN_DIR})
  message(FATAL_ERROR "NCNN not found at ${NCNN_DIR}")
endif()
set(ncnn_DIR ${NCNN_DIR}/${ANDROID_ABI}/lib/cmake/ncnn)
find_package(ncnn REQUIRED)

if(NOT EXISTS ${OpenCV_DIR})
  message(FATAL_ERROR "OpenCV Mobile not found at ${OpenCV_DIR}")
endif()
find_package(OpenCV REQUIRED core imgproc)

add_library(pinpic_ocr SHARED
  pinpic_ocr_jni.cpp
  ppocrv5_full.cpp
  omp_stubs.cpp
)

target_include_directories(pinpic_ocr PRIVATE ${CMAKE_SOURCE_DIR})

# OpenCV Mobile 4.13 pulls LLVM OpenMP symbols via KleidiCV. Link the NDK's
# static libomp for the active ABI.
if(ANDROID_ABI STREQUAL "arm64-v8a")
  set(_OMP_ARCH aarch64)
elseif(ANDROID_ABI STREQUAL "armeabi-v7a")
  set(_OMP_ARCH arm)
elseif(ANDROID_ABI STREQUAL "x86_64")
  set(_OMP_ARCH x86_64)
elseif(ANDROID_ABI STREQUAL "x86")
  set(_OMP_ARCH i386)
else()
  message(FATAL_ERROR "Unsupported ANDROID_ABI for OpenMP: ${ANDROID_ABI}")
endif()

set(_OMP_LIB
  ${ANDROID_NDK}/toolchains/llvm/prebuilt/${ANDROID_HOST_TAG}/lib/clang/18/lib/linux/${_OMP_ARCH}/libomp.a
)
if(NOT EXISTS ${_OMP_LIB})
  # Fallback for slightly different clang resource versions.
  file(GLOB _OMP_CANDIDATES
    "${ANDROID_NDK}/toolchains/llvm/prebuilt/${ANDROID_HOST_TAG}/lib/clang/*/lib/linux/${_OMP_ARCH}/libomp.a"
  )
  list(GET _OMP_CANDIDATES 0 _OMP_LIB)
endif()

target_link_libraries(pinpic_ocr
  ncnn
  ${OpenCV_LIBS}
  ${_OMP_LIB}
  android
  log
  jnigraphics
)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  target_compile_options(pinpic_ocr PRIVATE -O3 -fvisibility=hidden)
endif()
