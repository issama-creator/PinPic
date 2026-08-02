// Weak stubs for OpenMP symbols that OpenCV Mobile 4.13 references via
// KleidiCV but that are missing from some NDK libomp builds.
extern "C" {

__attribute__((weak)) void __kmpc_dispatch_deinit(void* /*loc*/) {}

}
