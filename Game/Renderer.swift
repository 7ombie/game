import SwiftUI
import MetalKit

struct Renderer: NSViewRepresentable {

    func makeNSView(context: Context) -> MTKView {

        let view = MTKView()

        view.delegate = context.coordinator
        view.device = context.coordinator.device
        view.colorPixelFormat = colorPixelFormat
        view.drawableSize = view.frame.size
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        view.needsDisplay = true
        view.isPaused = false

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) { }

    func makeCoordinator() -> Coordinator { Coordinator() }
}

class Coordinator: NSObject, MTKViewDelegate {

    var device: any MTLDevice

    private var level: Level
    private var uniforms: Uniforms
    private var keyboard: Keyboard

    private let viewport: MTLViewport
    private let textures: any MTLTexture
    private let vertexBuffer: any MTLBuffer
    private let tilemapBuffer: any MTLBuffer
    private let pipelineState: any MTLRenderPipelineState
    private let samplerState: any MTLSamplerState
    private let commandQueue: any MTLCommandQueue

    override init() {

        device = MTLCreateSystemDefaultDevice()!

        let label = "Background Shader"
        let library = device.makeDefaultLibrary()!
        let pipelineDescriptor = makeRenderPipelineDescriptor(pixelShader: "tile", label: label, library: library)
        let samplerDescriptor = makeSampleDescriptor()
        let loader = MTKTextureLoader(device: device)

        level = levels[0]
        keyboard = Keyboard()
        viewport = MTLViewport(width: 2560, height: 1600)
        uniforms = Uniforms(zoom: 4, camera: [0, 0], gridSize: level.gridSize)
        textures = try! loader.newTexture(name: "Tileset", scaleFactor: 1.0, bundle: nil, options: [.generateMipmaps: false, .SRGB: true])
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        tilemapBuffer = device.makeBuffer(bytes: level.tilemap, length: level.bufferLength, options: [])!
        vertexBuffer = device.makeBuffer(bytes: Canvas.vertices, length: Canvas.bufferLength, options: [])!
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        commandQueue = device.makeCommandQueue()!

        super.init()

        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) {

            [self] event in keyboard.handle(event: event)

            return nil
        }
    }

    func draw(in view: MTKView) {

        let buffer = self.commandQueue.makeCommandBuffer()!
        let descriptor = view.currentRenderPassDescriptor!
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!

        keyboard.update(uniforms: &uniforms, level: level)

        encoder.setViewport(self.viewport)
        encoder.setRenderPipelineState(self.pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.setFragmentTexture(textures, index: 0)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.setFragmentBuffer(tilemapBuffer, offset: 0, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        buffer.present(view.currentDrawable!)
        buffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { /* */ }
}

