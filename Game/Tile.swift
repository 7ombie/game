struct Tile {

    enum Inversion: UInt16 { case none, horizontal, vertical, combined }

    enum Gate { case east, north, west, south }

    typealias Gateset = [Gate: Bool]

    let encoded: UInt16
    let gateset: Gateset

    init(index: UInt16, rotate: Bool, inversion: Inversion, gates: [Bool]) {

        assert(gates.count == 4, "Invalid gateset count")

        self.encoded = (index << 3) | (rotate ? 4 : 0) | (inversion.rawValue)
        self.gateset = [.east: gates[0], .north: gates[1], .west: gates[2], .south: gates[3]]
    }

    func check(gate: Gate) -> Bool { gateset[gate]! }
}

let border   = Tile(index: 0, rotate: false, inversion: .none, gates: [false, false, false, false])
let floor    = Tile(index: 1, rotate: false, inversion: .none, gates: [true, true, true, true])
let nWall    = Tile(index: 2, rotate: false, inversion: .combined, gates: [true, false, true, true])
let sWall    = Tile(index: 2, rotate: false, inversion: .none, gates: [true, true, true, false])
let eWall    = Tile(index: 2, rotate: true,  inversion: .horizontal, gates: [false, true, true, true])
let wWall    = Tile(index: 2, rotate: true,  inversion: .vertical, gates: [true, true, false, true])
let nwCorner = Tile(index: 4, rotate: false, inversion: .combined, gates: [true, false, false, true])
let swCorner = Tile(index: 5, rotate: false, inversion: .none, gates: [true, true, false, false])
let neCorner = Tile(index: 5, rotate: false, inversion: .combined, gates: [false, false, true, true])
let seCorner = Tile(index: 4, rotate: false, inversion: .none, gates: [false, true, true, false])
let hAlley   = Tile(index: 3, rotate: false, inversion: .none, gates: [true, false, true, false])
let vAlley   = Tile(index: 3, rotate: true,  inversion: .horizontal, gates: [false, true, false, true])
let nRoom    = Tile(index: 6, rotate: true,  inversion: .vertical, gates: [false, false, false, true])
let sRoom    = Tile(index: 6, rotate: true,  inversion: .horizontal, gates: [false, true, false, false])
let eRoom    = Tile(index: 6, rotate: false, inversion: .none, gates: [false, false, true, false])
let wRoom    = Tile(index: 6, rotate: false, inversion: .combined, gates: [true, false, false, false])
let xRoom    = Tile(index: 7, rotate: false, inversion: .none, gates: [false, false, false, false])
