struct Level {

    let gridSize: Intx2
    let number, area, length: Int

    var grid: [Location] = []

    var tilemap: [Tile] { grid.map(\.tile!) }

    init(_ number: Int, gridSize: Intx2) {

        func selectEntrypoint() -> Location? {

            var lowestCount = Int.max
            var lowestLocations: [Location] = []

            for location in grid where location.tile == nil {

                let count = location.tilespace.count

                if count == lowestCount { lowestLocations.append(location) }
                else if count < lowestCount { (lowestCount, lowestLocations) = (count, [location]) }
            }

            return lowestLocations.randomElement() // returns `nil` when empty
        }

        self.number = number
        self.gridSize = gridSize
        self.area = gridSize.x * gridSize.y
        self.length = area * MemoryLayout<Tile>.stride

        for index in 0 ..< area { grid.append(Location(at: index)) }

        for location in grid { location.referenceNeighbours(in: grid, of: gridSize) }

        while let location = selectEntrypoint() { location.collapseTilespace() }
    }
}

class Location {

    let index: Int

    var tile: Tile?

    unowned var east:  Location!
    unowned var north: Location!
    unowned var west:  Location!
    unowned var south: Location!

    var tilespace: Set = [
        OPEN_FLOOR, EASTERN_WALL, NORTHERN_WALL, WESTERN_WALL, SOUTHERN_WALL,
        NORTHEAST_CORNER, SOUTHEAST_CORNER, NORTHWEST_CORNER, SOUTHWEST_CORNER,
        EASTERN_ROOM, NORTHERN_ROOM, WESTERN_ROOM, SOUTHERN_ROOM, ENCLOSED_ROOM,
        HORIZONTAL_ALLEY, VERTICAL_ALLEY
    ]

    init(at index: Int) { self.index = index }

    func referenceNeighbours(in grid: [Location], of gridSize: Intx2) {

        let x = index % gridSize.x
        let y = index / gridSize.x

        east  = grid[x < gridSize.x - 1 ? index + 1 : y * gridSize.x]
        north = y > 0 ? grid[index - gridSize.x] : nil
        west  = grid[x > 0 ? index - 1 : y * gridSize.x + gridSize.x - 1]
        south = y < gridSize.y - 1 ? grid[index + gridSize.x] : nil
    }

    func collapseTilespace() {

        func isAdjacent(to tile: Tile) -> Bool {

            return isHorizontallyAdjacent(to: tile) || isVerticallyAdjacent(to: tile)
        }

        func isHorizontallyAdjacent(to tile: Tile) -> Bool {

            if let adjacentTile = east.tile, adjacentTile == tile { return true }
            if let adjacentTile = west.tile, adjacentTile == tile { return true }

            return false
        }

        func isVerticallyAdjacent(to tile: Tile) -> Bool {

            if let adjacentTile = north?.tile, adjacentTile == tile { return true }
            if let adjacentTile = south?.tile, adjacentTile == tile { return true }

            return false
        }

        func random(when adjacent: (Tile) -> Bool, to tile: Tile, wins odds: Int, of total: Int) -> Bool {

            tilespace.contains(tile) && adjacent(tile) && Int.random(in: 1 ... total) <= odds
        }

        tile = if random(when: isAdjacent, to: OPEN_FLOOR, wins: 4, of: 5) {

            OPEN_FLOOR

        } else if random(when: isHorizontallyAdjacent, to: HORIZONTAL_ALLEY, wins: 49, of: 50) {

            HORIZONTAL_ALLEY

        } else if random(when: isVerticallyAdjacent, to: VERTICAL_ALLEY, wins: 49, of: 50) {

            VERTICAL_ALLEY

        } else { tilespace.randomElement() }

        tilespace = [tile!]
        notifyNeighbours()
    }

    func notifyNeighbours() {

        var easternCongruents:  Set<Tile> = []
        var northernCongruents: Set<Tile> = []
        var westernCongruents:  Set<Tile> = []
        var southernCongruents: Set<Tile> = []

        for candidate in tilespace {

            easternCongruents.formUnion(congruents[candidate]!.east)
            northernCongruents.formUnion(congruents[candidate]!.north)
            westernCongruents.formUnion(congruents[candidate]!.west)
            southernCongruents.formUnion(congruents[candidate]!.south)
        }

        if east.tile == nil { east.intersectTilespace(with: easternCongruents)  }
        if west.tile == nil { west.intersectTilespace(with: westernCongruents)  }

        if let north, north.tile == nil { north.intersectTilespace(with: northernCongruents) }
        if let south, south.tile == nil { south.intersectTilespace(with: southernCongruents) }
    }

    func intersectTilespace(with congruents: Set<Tile>) {

        let initialCount = tilespace.count

        tilespace.formIntersection(congruents)

        if tilespace.count == 1 { tile = tilespace.first }

        if tilespace.count < initialCount { notifyNeighbours() }
    }
}
