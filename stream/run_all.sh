#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: ./run_all.sh <result_dir>"
    exit 1
fi

RESULT_DIR=$1

echo "Benchmarking with Metal"
pushd MetalStream
xcodebuild
popd
MetalStream/build/Release/MetalStream > "$RESULT_DIR/metal.csv"

echo "Benchmarking with OpenMP"
pushd BabelStream
make -f OpenMP.make COMPILER=CLANG TARGET=CPU
popd
OMP_NUM_THREADS=1 BabelStream/omp-stream --float --csv > $RESULT_DIR/openmp1.csv
OMP_NUM_THREADS=4 BabelStream/omp-stream --float --csv > $RESULT_DIR/openmp4.csv
OMP_NUM_THREADS=8 BabelStream/omp-stream --float --csv > $RESULT_DIR/openmp8.csv

cd "$RESULT_DIR"
gnuplot plot_stream.gpi
