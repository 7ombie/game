typealias Tile = UInt16

extension Tile {

    static let size = 32

    enum Inversion: Tile { case none, horizontal, vertical, combined }

    init(index: Self, rotate: Bool, inversion: Inversion) {

        self = (index << 3) | (rotate ? 4 : 0) | (inversion.rawValue)
    }
}

struct Congruents {

    enum Edge { case wall, door }

    let east, north, west, south: Set<Tile>

    private let eastern_door: Set = [
        OPEN_FLOOR, EASTERN_WALL, NORTHERN_WALL, SOUTHERN_WALL,
        NORTHEAST_CORNER, SOUTHEAST_CORNER,
        HORIZONTAL_ALLEY, EASTERN_ROOM
    ]

    private let northern_door: Set = [
        OPEN_FLOOR, EASTERN_WALL, NORTHERN_WALL, WESTERN_WALL,
        NORTHEAST_CORNER, NORTHWEST_CORNER,
        VERTICAL_ALLEY, NORTHERN_ROOM
    ]

    private let western_door: Set = [
        OPEN_FLOOR, NORTHERN_WALL, WESTERN_WALL, SOUTHERN_WALL,
        NORTHWEST_CORNER, SOUTHWEST_CORNER,
        HORIZONTAL_ALLEY, WESTERN_ROOM
    ]

    private let southern_door: Set = [
        OPEN_FLOOR, EASTERN_WALL, WESTERN_WALL, SOUTHERN_WALL,
        SOUTHEAST_CORNER, SOUTHWEST_CORNER,
        VERTICAL_ALLEY, SOUTHERN_ROOM
    ]

    private let eastern_wall: Set = [
        WESTERN_WALL, NORTHWEST_CORNER, SOUTHWEST_CORNER, VERTICAL_ALLEY,
        NORTHERN_ROOM, WESTERN_ROOM, SOUTHERN_ROOM, ENCLOSED_ROOM
    ]

    private let northern_wall: Set = [
        SOUTHERN_WALL, SOUTHEAST_CORNER, SOUTHWEST_CORNER, HORIZONTAL_ALLEY,
        EASTERN_ROOM, WESTERN_ROOM, SOUTHERN_ROOM, ENCLOSED_ROOM
    ]

    private let western_wall: Set = [
        EASTERN_WALL, NORTHEAST_CORNER, SOUTHEAST_CORNER, VERTICAL_ALLEY,
        EASTERN_ROOM, NORTHERN_ROOM, SOUTHERN_ROOM, ENCLOSED_ROOM
    ]

    private let southern_wall: Set = [
        NORTHERN_WALL, NORTHEAST_CORNER, NORTHWEST_CORNER, HORIZONTAL_ALLEY,
        EASTERN_ROOM, NORTHERN_ROOM, WESTERN_ROOM, ENCLOSED_ROOM
    ]

    init(east: Edge, north: Edge, west: Edge, south: Edge) {

        self.east  = east  == .door ? eastern_door  : eastern_wall
        self.north = north == .door ? northern_door : northern_wall
        self.west  = west  == .door ? western_door  : western_wall
        self.south = south == .door ? southern_door : southern_wall
    }
}

let VOID_FLOOR       = Tile(index: 0, rotate: false, inversion: .none)
let OPEN_FLOOR       = Tile(index: 1, rotate: false, inversion: .none)
let EASTERN_WALL     = Tile(index: 2, rotate: true,  inversion: .horizontal)
let NORTHERN_WALL    = Tile(index: 2, rotate: false, inversion: .combined)
let WESTERN_WALL     = Tile(index: 2, rotate: true,  inversion: .vertical)
let SOUTHERN_WALL    = Tile(index: 2, rotate: false, inversion: .none)
let NORTHEAST_CORNER = Tile(index: 5, rotate: false, inversion: .combined)
let SOUTHEAST_CORNER = Tile(index: 4, rotate: false, inversion: .none)
let NORTHWEST_CORNER = Tile(index: 4, rotate: false, inversion: .combined)
let SOUTHWEST_CORNER = Tile(index: 5, rotate: false, inversion: .none)
let EASTERN_ROOM     = Tile(index: 6, rotate: false, inversion: .none)
let NORTHERN_ROOM    = Tile(index: 6, rotate: true,  inversion: .vertical)
let WESTERN_ROOM     = Tile(index: 6, rotate: false, inversion: .combined)
let SOUTHERN_ROOM    = Tile(index: 6, rotate: true,  inversion: .horizontal)
let ENCLOSED_ROOM    = Tile(index: 7, rotate: false, inversion: .none)
let HORIZONTAL_ALLEY = Tile(index: 3, rotate: false, inversion: .none)
let VERTICAL_ALLEY   = Tile(index: 3, rotate: true,  inversion: .horizontal)

let congruents: [Tile: Congruents] = [
    OPEN_FLOOR:       Congruents(east: .door, north: .door, west: .door, south: .door),
    EASTERN_WALL:     Congruents(east: .wall, north: .door, west: .door, south: .door),
    NORTHERN_WALL:    Congruents(east: .door, north: .wall, west: .door, south: .door),
    WESTERN_WALL:     Congruents(east: .door, north: .door, west: .wall, south: .door),
    SOUTHERN_WALL:    Congruents(east: .door, north: .door, west: .door, south: .wall),
    NORTHEAST_CORNER: Congruents(east: .wall, north: .wall, west: .door, south: .door),
    SOUTHEAST_CORNER: Congruents(east: .wall, north: .door, west: .door, south: .wall),
    NORTHWEST_CORNER: Congruents(east: .door, north: .wall, west: .wall, south: .door),
    SOUTHWEST_CORNER: Congruents(east: .door, north: .door, west: .wall, south: .wall),
    EASTERN_ROOM:     Congruents(east: .wall, north: .wall, west: .door, south: .wall),
    NORTHERN_ROOM:    Congruents(east: .wall, north: .wall, west: .wall, south: .door),
    WESTERN_ROOM:     Congruents(east: .door, north: .wall, west: .wall, south: .wall),
    SOUTHERN_ROOM:    Congruents(east: .wall, north: .door, west: .wall, south: .wall),
    ENCLOSED_ROOM:    Congruents(east: .wall, north: .wall, west: .wall, south: .wall),
    HORIZONTAL_ALLEY: Congruents(east: .door, north: .wall, west: .door, south: .wall),
    VERTICAL_ALLEY:   Congruents(east: .wall, north: .door, west: .wall, south: .door),
]
