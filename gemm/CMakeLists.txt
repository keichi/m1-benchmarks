cmake_minimum_required(VERSION 3.19)

set(CMAKE_CXX_STANDARD 17)

project(GEMMBench)

add_executable(gemm_bench main.cpp)

set(BACKEND "Accelerate" CACHE STRING "GEMM backend library")
set(DTYPE "FLOAT" CACHE STRING "Matrix element type")

if(BACKEND STREQUAL "OpenBLAS")
  set(BLA_VENDOR OpenBLAS)
  find_package(BLAS REQUIRED)
  target_link_libraries(gemm_bench PRIVATE BLAS::BLAS)
  target_compile_definitions(gemm_bench PRIVATE USE_OPENBLAS)
elseif(BACKEND STREQUAL "Accelerate")
  set(BLA_VENDOR Apple)
  find_package(BLAS REQUIRED)
  target_link_libraries(gemm_bench PRIVATE BLAS::BLAS)
  target_compile_definitions(gemm_bench PRIVATE USE_ACCELERATE)
elseif(BACKEND STREQUAL "Eigen")
  find_package(Eigen3 REQUIRED)
  find_package(OpenMP REQUIRED)
  target_link_libraries(gemm_bench PRIVATE Eigen3::Eigen)
  target_link_libraries(gemm_bench PRIVATE OpenMP::OpenMP_CXX)
  target_compile_definitions(gemm_bench PRIVATE USE_EIGEN)
elseif(BACKEND STREQUAL "Metal")
  enable_language(OBJCXX)
  set_source_files_properties(main.cpp PROPERTIES LANGUAGE OBJCXX)
  target_link_libraries(gemm_bench PRIVATE "-framework CoreGraphics")
  target_link_libraries(gemm_bench PRIVATE "-framework Foundation")
  target_link_libraries(gemm_bench PRIVATE "-framework Metal")
  target_link_libraries(gemm_bench PRIVATE "-framework MetalPerformanceShaders")
  target_compile_definitions(gemm_bench PRIVATE USE_METAL)
else()
  message(FATAL_ERROR "Unknown GEMM backend")
endif()

if(DTYPE STREQUAL "FLOAT")
  target_compile_definitions(gemm_bench PRIVATE DTYPE_FLOAT)
elseif(DTYPE STREQUAL "DOUBLE")
  target_compile_definitions(gemm_bench PRIVATE DTYPE_DOUBLE)
else()
  message(FATAL_ERROR "Unknown data type")
endif()
