import SwiftUI
import MetalKit

struct Renderer: NSViewRepresentable {

    func makeNSView(context: Context) -> MTKView {

        let view = MTKView()

        view.delegate = context.coordinator
        view.device = context.coordinator.device
        view.colorPixelFormat = COLOR_PIXEL_FORMAT
        view.drawableSize = view.frame.size
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = false
        view.needsDisplay = true
        view.isPaused = false

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) { /* */ }

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
    private let pipelineState: any MTLRenderPipelineState
    private let samplerState: any MTLSamplerState
    private let commandQueue: any MTLCommandQueue

    override init() {

        device = MTLCreateSystemDefaultDevice()!

        let loader = MTKTextureLoader(device: device)
        let samplerDescriptor = MTLSamplerDescriptor(normalized: false, filter: .nearest)
        let pipelineDescriptor = MTLRenderPipelineDescriptor(fragShader: "tile", library: device.makeDefaultLibrary()!)

        level = Level(1, gridSize: [32, 13])

        keyboard = Keyboard()
        uniforms = Uniforms(zoom: 4, gridSize: level.gridSize)
        viewport = MTLViewport(width: 2560, height: 1600)
        textures = try! loader.newTexture(name: "Tileset", scaleFactor: 1.0, bundle: nil, options: [.generateMipmaps: false, .SRGB: true])

        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        vertexBuffer  = device.makeBuffer(bytes: Canvas.vertices, length: Canvas.length, options: [])!
        samplerState  = device.makeSamplerState(descriptor: samplerDescriptor)!
        commandQueue  = device.makeCommandQueue()!

        super.init()

        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) {

            [self] event in keyboard.handle(event: event)

            return nil
        }
    }

    func draw(in view: MTKView) {

        let buffer = commandQueue.makeCommandBuffer()!
        let descriptor = view.currentRenderPassDescriptor!
        let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor)!
        let tilemap = device.makeBuffer(bytes: level.tilemap, length: level.length, options: [])!

        keyboard.update(uniforms: &uniforms, viewport: viewport)

        encoder.setViewport(viewport)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

        encoder.setFragmentTexture(textures, index: 0)
        encoder.setFragmentSamplerState(samplerState, index: 0)
        encoder.setFragmentBuffer(tilemap, offset: 0, index: 0)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)

        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()

        buffer.present(view.currentDrawable!)
        buffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { /* */ }
}

