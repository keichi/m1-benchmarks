//
//  kernels.metal
//  MetalStream
//
//  Created by Keichi Takahashi on 2020/12/31.
//

#include <metal_stdlib>
using namespace metal;

constant uint ARRAY_LEN = 64 * 1024 * 1024;
constant uint THREADGROUP_SIZE = 256;
constant uint NUM_THREADGROUPS = 1024;

kernel void Init(device float* A,
                 device float* B,
                 device float* C,
                 uint idx [[thread_position_in_grid]])
{
    A[idx] = 1.0f;
    B[idx] = 2.0f;
    C[idx] = 0.0f;
}

kernel void Copy(device const float* A,
                 device const float* B,
                 device float* C,
                 uint idx [[thread_position_in_grid]])
{
    C[idx] = A[idx];
}

kernel void Mul(device const float* A,
                device const float* B,
                device float* C,
                uint idx [[thread_position_in_grid]])
{
    C[idx] = 0.4f * A[idx];
}

kernel void Add(device const float* A,
                device const float* B,
                device float* C,
                uint idx [[thread_position_in_grid]])
{
    C[idx] = A[idx] + B[idx];
}

kernel void Triad(device const float* A,
                  device const float* B,
                  device float* C,
                  uint idx [[thread_position_in_grid]])
{
    C[idx] = A[idx] + 0.4f * B[idx];
}

kernel void Dot(device const float* A,
                device const float* B,
                device float* C,
                uint idx [[thread_position_in_grid]],
                uint local_idx [[thread_index_in_threadgroup]],
                uint block_idx [[threadgroup_position_in_grid]])
{
    threadgroup float shared_sum[THREADGROUP_SIZE];

    shared_sum[local_idx] = 0.0f;
    for (; idx < ARRAY_LEN; idx += THREADGROUP_SIZE * NUM_THREADGROUPS) {
        shared_sum[local_idx] += A[idx] * B[idx];
    }

    for (uint offset = THREADGROUP_SIZE / 2; offset > 0; offset /= 2) {
        threadgroup_barrier(mem_flags::mem_none);
        if (local_idx < offset) {
            shared_sum[local_idx] += shared_sum[local_idx + offset];
        }
    }

    if (local_idx == 0) {
        C[block_idx] = shared_sum[local_idx];
    }
}
