//
//  main.swift
//  MetalStream
//
//  Created by Keichi Takahashi on 2020/12/31.
//

import Foundation
import Metal

class Stream {
    let ARRAY_LEN = 64 * 1024 * 1024
    let THREADGROUP_SIZE = 256
    let NUM_THREADGROUPS = 1024
    let NUM_ITER = 100

    var device: MTLDevice
    var queue: MTLCommandQueue
    var library: MTLLibrary

    let bufferA: MTLBuffer
    let bufferB: MTLBuffer
    let bufferC: MTLBuffer

    init() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.queue = device.makeCommandQueue()!
        self.library = device.makeDefaultLibrary()!

        self.bufferA = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                          options: .storageModeShared)!
        self.bufferB = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                          options: .storageModeShared)!
        self.bufferC = device.makeBuffer(length: ARRAY_LEN * MemoryLayout<Float>.stride,
                                          options: .storageModeShared)!
    }

    func runKernel(kernel: String, gridSize: Int, tbSize: Int) -> Double {
        let commandBuffer = queue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!

        let function = library.makeFunction(name: kernel)
        let functionPSO = try! device.makeComputePipelineState(function: function!)

        commandEncoder.setComputePipelineState(functionPSO)
        commandEncoder.setBuffer(bufferA, offset: 0, index: 0)
        commandEncoder.setBuffer(bufferB, offset: 0, index: 1)
        commandEncoder.setBuffer(bufferC, offset: 0, index: 2)

        let gridSize = MTLSizeMake(gridSize, 1, 1)
        let threadGroupSize = MTLSizeMake(tbSize, 1, 1)

        commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        commandEncoder.endEncoding()

        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        return commandBuffer.gpuEndTime - commandBuffer.gpuStartTime
    }

    func benchmarkKernel(kernel: String, gridSize: Int, tbSize: Int, multiplier: Int) {
        var timings: [Double] = []

        for _ in 1...NUM_ITER {
            let runtime = self.runKernel(kernel: kernel, gridSize: gridSize, tbSize: tbSize)
            timings.append(runtime)
        }

        let min_runtime = timings.min()!
        let max_runtime = timings.max()!
        let avg_runtime = timings.reduce(0.0, +) / Double(timings.count)
        let bw = Double(ARRAY_LEN * MemoryLayout<Float>.stride * multiplier) / min_runtime / 1e6

        let row = [
            kernel,
            String(NUM_ITER),
            String(ARRAY_LEN),
            String(MemoryLayout<Float>.stride),
            String(bw),
            String(min_runtime),
            String(max_runtime),
            String(avg_runtime)
        ]

        print(row.joined(separator: ","))
    }

    func run() {
        let header = [
            "function",
            "num_times",
            "n_elements",
            "sizeof",
            "max_mbytes_per_sec",
            "min_runtime",
            "max_runtime",
            "avg_runtime"
        ]

        print(header.joined(separator: ","))

        let _ = runKernel(kernel: "Init", gridSize: ARRAY_LEN, tbSize: THREADGROUP_SIZE)

        benchmarkKernel(kernel: "Copy", gridSize: ARRAY_LEN, tbSize: THREADGROUP_SIZE,
                        multiplier: 2)
        benchmarkKernel(kernel: "Mul", gridSize: ARRAY_LEN, tbSize: THREADGROUP_SIZE,
                        multiplier: 2)
        benchmarkKernel(kernel: "Add", gridSize: ARRAY_LEN, tbSize: THREADGROUP_SIZE,
                        multiplier: 3)
        benchmarkKernel(kernel: "Triad", gridSize: ARRAY_LEN, tbSize: THREADGROUP_SIZE,
                        multiplier: 3)
        benchmarkKernel(kernel: "Dot", gridSize: NUM_THREADGROUPS * THREADGROUP_SIZE,
                        tbSize: THREADGROUP_SIZE, multiplier: 2)
    }
}


let stream = Stream()
stream.run()
