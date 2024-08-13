import MetalKit

typealias Intx2 = SIMD2<Int>
typealias Floatx2 = SIMD2<Float>
typealias UInt32x2 = SIMD2<UInt32>

let COLOR_PIXEL_FORMAT = MTLPixelFormat.bgra8Unorm_srgb

struct Canvas {

    static let vertices: [Floatx2] = [[-1, +1],  [+1, +1],  [-1, -1],  [+1, -1]]
    static let length = 4 * MemoryLayout<Floatx2>.stride
}

extension MTLViewport {

    init(width x: Double, height y: Double) {

        self.init(originX: 0, originY: 0, width: x, height: y, znear: 0, zfar: 1)
    }
}

extension MTLRenderPipelineDescriptor {

    convenience init(fragShader name: String, library: some MTLLibrary, label: String? = nil) {

        self.init()
        self.label = label ?? "Pixel Shader: \(name)"

        vertexFunction = library.makeFunction(name: "canvas")
        fragmentFunction = library.makeFunction(name: name)
        colorAttachments[0].pixelFormat = COLOR_PIXEL_FORMAT

        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor?.attributes[0].format = .float2
        vertexDescriptor?.layouts[0].stride = MemoryLayout<Floatx2>.stride
    }
}

extension MTLSamplerDescriptor {

    convenience init(normalized: Bool, filter: MTLSamplerMinMagFilter) {

        self.init()

        normalizedCoordinates = normalized
        minFilter = filter
        magFilter = filter
    }
}
