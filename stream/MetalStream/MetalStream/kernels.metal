//
//  kernels.metal
//  MetalStream
//
//  Created by Keichi Takahashi on 2020/12/31.
//

#include <metal_stdlib>
using namespace metal;


kernel void add_arrays(device const float* A,
                       device const float* B,
                       device float* C,
                       uint index [[thread_position_in_grid]])
{
    C[index] = A[index] + B[index];
}
