#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: ./run_all.sh <result_dir>"
    exit 1
fi

RESULT_DIR=$1

echo "Benchmarking with Accelerate"
mkdir -p build-accelerate
pushd build-accelerate
cmake -DDTYPE=FLOAT -DBACKEND=Accelerate -DCMAKE_BUILD_TYPE=Release ..
make
popd
build-accelerate/gemm_bench > "$RESULT_DIR/accelerate.dat"

echo "Benchmarking with OpenBLAS"
mkdir -p build-openblas
pushd build-openblas
LDFLAGS=-L$(brew --prefix openblas)/lib cmake -DDTYPE=FLOAT -DBACKEND=OpenBLAS -DCMAKE_BUILD_TYPE=Release ..
CPATH=$(brew --prefix openblas)/include make
popd
build-openblas/gemm_bench > "$RESULT_DIR/openblas.dat"

echo "Benchmarking with Eigen"
mkdir -p build-eigen
pushd build-eigen
cmake -DDTYPE=FLOAT -DBACKEND=Eigen -DCMAKE_BUILD_TYPE=Release ..
make
popd
build-eigen/gemm_bench > "$RESULT_DIR/eigen.dat"

echo "Benchmarking with Metal"
mkdir -p build-metal
pushd build-metal
cmake -DDTYPE=FLOAT -DBACKEND=Metal -DCMAKE_BUILD_TYPE=Release ..
make
popd
build-metal/gemm_bench > "$RESULT_DIR/metal.dat"

cd "$RESULT_DIR"
gnuplot plot_gemm.gpi
