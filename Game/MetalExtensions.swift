import MetalKit

typealias Floatx2 = SIMD2<Float>
typealias Int32x2 = SIMD2<Int32>

let colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb

extension MTLViewport {

    init(width x: Double, height y: Double) {

        self.init(originX: 0, originY: 0, width: x, height: y, znear: 0, zfar: 1)
    }
}

struct Canvas {

    static let vertices: [Floatx2] = [[-1, +1],  [+1, +1],  [-1, -1],  [+1, -1]]
    static let bufferLength = 4 * MemoryLayout<Floatx2>.stride
}

func makeRenderPipelineDescriptor(pixelShader name: String, label: String, library: some MTLLibrary) -> MTLRenderPipelineDescriptor {

    let descriptor = MTLRenderPipelineDescriptor()

    descriptor.label = label
    descriptor.vertexFunction = library.makeFunction(name: "canvas")
    descriptor.fragmentFunction = library.makeFunction(name: name)
    descriptor.colorAttachments[0].pixelFormat = colorPixelFormat

    descriptor.vertexDescriptor = MTLVertexDescriptor()
    descriptor.vertexDescriptor?.attributes[0].format = .float2
    descriptor.vertexDescriptor?.layouts[0].stride = MemoryLayout<Floatx2>.stride

    return descriptor
}

func makeSampleDescriptor(normalized: Bool = false, filter: MTLSamplerMinMagFilter = .nearest) -> MTLSamplerDescriptor {

    let descriptor = MTLSamplerDescriptor()

    descriptor.normalizedCoordinates = normalized
    descriptor.minFilter = filter
    descriptor.magFilter = filter

    return descriptor
}
