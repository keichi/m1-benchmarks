#!/bin/bash

mkdir -p result

echo "Benchmarking with Metal"
pushd MetalStream
xcodebuild
./build/Release/MetalStream > ../result/metal.csv
popd

echo "Benchmarking with OpenMP"
pushd BabelStream
make -f OpenMP.make COMPILER=CLANG TARGET=CPU
OMP_NUM_THREADS=1 ./omp-stream --float --csv > ../result/openmp1.csv
OMP_NUM_THREADS=4 ./omp-stream --float --csv > ../result/openmp4.csv
OMP_NUM_THREADS=8 ./omp-stream --float --csv > ../result/openmp8.csv
