import simd

struct Level {

    let number: Int
    let tilemap: [UInt16]
    let gridSize: Int32x2
    let extents: Int32x2
    let bufferLength: Int

    init(_ number: Int, gridSize: Int32x2, tiles: [Tile]) {

        let area = Int(gridSize.x) * Int(gridSize.y)

        assert(area == tiles.count, "Tilemap dimensions are invalid for Level \(number).")

        self.number = number
        self.tilemap = tiles.map { $0.encoded }
        self.gridSize = gridSize
        self.extents = gridSize &* 32
        self.bufferLength = area * MemoryLayout<UInt16>.stride
    }
}

let levels = [
    Level(1, gridSize: [8, 8], tiles: [
        nwCorner,  hAlley,  hAlley,    hAlley,    hAlley,    hAlley,    nWall,  neCorner,
        wWall,     hAlley,  hAlley,    hAlley,    hAlley,    neCorner,  wWall,  eWall,
        wWall,     nWall,   nWall,     neCorner,  xRoom,     vAlley,    wWall,  eWall,
        wWall,     sWall,   sWall,     sWall,     neCorner,  vAlley,    wWall,  eWall,
        vAlley,    border,  wRoom,     eRoom,     vAlley,    vAlley,    wWall,  eWall,
        vAlley,    border,  nwCorner,  nWall,     eWall,     vAlley,    wWall,  eWall,
        wWall,     nWall,   floor,     floor,     eWall,     vAlley,    wWall,  eWall,
        swCorner,  sWall,   sWall,     sWall,     sWall,     sWall,     sWall,  seCorner,
    ])
]
