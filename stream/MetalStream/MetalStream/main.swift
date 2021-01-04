//
//  main.swift
//  MetalStream
//
//  Created by Keichi Takahashi on 2020/12/31.
//

import Foundation
import Metal

let ARRAY_LEN = 1024 * 1024 * 100

let device = MTLCreateSystemDefaultDevice()!
let queue = device.makeCommandQueue()!
let library = device.makeDefaultLibrary()!
let function = library.makeFunction(name: "add_arrays")!
let pipelineState = try device.makeComputePipelineState(function: function)
let functionPSO = try device.makeComputePipelineState(function: function)

let commandBuffer = queue.makeCommandBuffer()!
let commandEncoder = commandBuffer.makeComputeCommandEncoder()!

let bufferA = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                options: .storageModeShared)
let bufferB = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                options: .storageModeShared)
let bufferC = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                options: .storageModeShared)

let ptrA = UnsafeMutablePointer<Float>(OpaquePointer(bufferA?.contents()))!
let ptrB = UnsafeMutablePointer<Float>(OpaquePointer(bufferB?.contents()))!
let ptrC = UnsafeMutablePointer<Float>(OpaquePointer(bufferC?.contents()))!

for i in 0..<ARRAY_LEN {
    ptrA[i] = 1.0
    ptrB[i] = 2.0
    ptrC[i] = 0.0
}

commandEncoder.setComputePipelineState(functionPSO)
commandEncoder.setBuffer(bufferA, offset: 0, index: 0)
commandEncoder.setBuffer(bufferB, offset: 0, index: 1)
commandEncoder.setBuffer(bufferC, offset: 0, index: 2)

let gridSize = MTLSizeMake(ARRAY_LEN, 1, 1)
let threadsPerGroup = min(functionPSO.maxTotalThreadsPerThreadgroup, ARRAY_LEN)
let threadGroupSize = MTLSizeMake(threadsPerGroup, 1, 1);
commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)

commandEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

let runtime = commandBuffer.gpuEndTime - commandBuffer.gpuStartTime
let bw = Double(ARRAY_LEN * MemoryLayout<Float>.stride * 3) / runtime / 1e9

print("Bandwidth: \(bw) GB/s")
