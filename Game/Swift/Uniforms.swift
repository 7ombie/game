import simd

struct Uniforms {

    var zoom: UInt32
    var camera: UInt32x2
    let gridSize: UInt32x2

    init(zoom: Int = 1, camera: Intx2 = [0, 0], gridSize: Intx2) {

        self.zoom = UInt32(zoom)
        self.camera = [UInt32(camera.x), UInt32(camera.y)]
        self.gridSize = [UInt32(gridSize.x), UInt32(gridSize.y)]
    }
}
