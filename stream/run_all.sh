#!/bin/bash

mkdir -p result

echo "Benchmarking with Metal"
pushd MetalStream
xcodebuild
./build/Release/MetalStream
popd

echo "Benchmarking with OpenMP"
pushd BabelStream
make -f OpenMP.make COMPILER=CLANG TARGET=CPU
./omp-stream
