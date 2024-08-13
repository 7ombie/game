class Level {

    let gridSize: Intx2
    let number, area, length: Int

    var locations: [Location]
    var tilemap: [Tile] { locations.map { location in location.tile ?? 0 } }

    init(_ number: Int, gridSize: Intx2) {

        self.number = number
        self.gridSize = gridSize
        self.area = gridSize.x * gridSize.y
        self.length = area * MemoryLayout<Tile>.stride
        self.locations = []

        for index in 0 ..< area { locations.append(Location(index: index, gridSize: gridSize)) }

        generate()
    }

    func generate() {

        func findStartingLocationIndex() -> Int? {

            var lowestCount = 18
            var lowestLocations: [Int] = []

            for location in locations where location.tile == nil {

                let count = location.tilespace.count

                if count == lowestCount { lowestLocations.append(location.i) }
                else if count < lowestCount {

                    lowestCount = count
                    lowestLocations = [location.i]
                }
            }

            return if lowestCount == 18 { nil } else { lowestLocations.randomElement()! }
        }

        func collapseTilespace(of location: Location) -> Location {

            func updateNeighbours(of location: Location) {

                func reduceTilespace(index: Int, congruents: Set<Tile>) {

                    let initialCount = locations[index].tilespace.count

                    if locations[index].tile == nil { locations[index].tilespace.formIntersection(congruents) }

                    let finalCount = locations[index].tilespace.count

                    if finalCount == 1 { locations[index].tile = locations[index].tilespace.first! }

                    if finalCount < initialCount { updateNeighbours(of: locations[index]) }
                }

                var easternCongruents:  Set<Tile> = []
                var northernCongruents: Set<Tile> = []
                var westernCongruents:  Set<Tile> = []
                var southernCongruents: Set<Tile> = []

                for tile in location.tilespace {

                    easternCongruents.formUnion(congruents[tile]!.east)
                    northernCongruents.formUnion(congruents[tile]!.north)
                    westernCongruents.formUnion(congruents[tile]!.west)
                    southernCongruents.formUnion(congruents[tile]!.south)
                }

                if location.east  != nil { reduceTilespace(index: location.east!,  congruents: easternCongruents)  }
                if location.north != nil { reduceTilespace(index: location.north!, congruents: northernCongruents) }
                if location.west  != nil { reduceTilespace(index: location.west!,  congruents: westernCongruents)  }
                if location.south != nil { reduceTilespace(index: location.south!, congruents: southernCongruents) }
            }

            var location = location
            let tile = location.tilespace.randomElement()!

            location.tile = tile
            location.tilespace = [tile]

            updateNeighbours(of: location)

            return location
        }

        while let index = findStartingLocationIndex() { locations[index] = collapseTilespace(of: locations[index]) }
    }
}

