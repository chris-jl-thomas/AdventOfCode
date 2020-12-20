import Foundation

extension TwentyTwenty {
    public class Day20 {
        public init() {
        }
        
        public enum Edge: CaseIterable {
            case top, right, bottom, left
        }
        
        public struct Tile: Hashable {
            public let number: Int
            public let rows: [String]
            public var rotations: Int
            public var flippedInX: Bool
            public var flippedInY: Bool
            
            public init(number: Int, rows: [String], rotations: Int, flippedInX: Bool, flippedInY: Bool) {
                self.number = number
                self.rows = rows
                self.rotations = rotations
                self.flippedInX = flippedInX
                self.flippedInY = flippedInY
            }
            
            public init(tileLines: [String]) {
                let number = Int(tileLines.first!.replacingOccurrences(of: "Tile ", with: "").replacingOccurrences(of: ":", with: ""))!
                
                self.number = number
                self.rows = Array(tileLines.dropFirst())
                self.rotations = 0
                self.flippedInX = false
                self.flippedInY = false
            }
            
            public func edge(_ edge: Edge) -> String {
                switch edge {
                case .top:
                    return rows.first!
                case .bottom:
                    return rows.last!
                case .left:
                    return String(rows.map { String($0.first!) }.joined().reversed())
                case .right:
                    return rows.map { String($0.last!) }.joined()
                }
            }
            
            public func allEdges() -> [String] {
                Edge.allCases.map { self.edge($0) }
            }
            
            public func flipX() -> Tile {
                return Tile(number: self.number, rows: self.rows.map { String($0.reversed()) }, rotations: rotations, flippedInX: !self.flippedInX, flippedInY: self.flippedInY)
            }
            
            public func flipY() -> Tile {
                return Tile(number: self.number, rows: self.rows.reversed(), rotations: rotations, flippedInX: self.flippedInX, flippedInY: !self.flippedInY)
            }
            
            public func edgesForAllFlippages() -> Set<String> {
                return Set(allEdges() + flipX().allEdges() + flipY().allEdges())
            }
            
            public func allTiles() -> Set<Tile> {
                var set = Set<Tile>()
                set.insert(self)
                set.insert(flipX())
                set.insert(flipY())
                for i in 1...3 {
                    set.insert(rotateRight(rotations: i))
                    set.insert(flipX().rotateRight(rotations: i))
                    set.insert(flipY().rotateRight(rotations: i))
                }
                
                return set
            }
            
            public func rotateRight() -> Tile {
                let count = rows.count - 1
                var newRows: [String] = []
                
                for _ in 0 ... (count) {
                    newRows.append("")
                }
                
                rows.forEach { row in
                    row.enumerated().forEach { (index, character) in
                        newRows[count - index] = String(character) + (newRows[count - index])
                    }
                }

                return Tile(number: self.number, rows: newRows.reversed(), rotations: (self.rotations + 1) % 4, flippedInX: self.flippedInX, flippedInY: self.flippedInY)
            }
            
            func rotateRight(rotations: Int) -> Tile {
                var tile = self
                for _ in 1 ... rotations {
                    tile = tile.rotateRight()
                }
                
                return tile
            }
        }
        
    }
    
}

extension TwentyTwenty.Day20 {
    public func solvePart1(input: [String]) -> Int {
        
        let tiles = input.map { tile -> Tile in
            Tile(tileLines: tile.components(separatedBy: "\n"))
        }
        
        // dont need flipped in x and y as that is the same result as not flipped!
        let allPossibleTilesFlipped = tiles.flatMap { tile in
            return [tile, tile.flipX(), tile.flipY()]
        }
        
        let allEdges = allPossibleTilesFlipped.flatMap { $0.allEdges() }
        var allEdgesWithCounts = [String: Int]()
        
        allEdges.forEach { edge in
            let value = allEdgesWithCounts[edge] ?? 0
            allEdgesWithCounts[edge] = (value + 1)
        }
        
        let edgesWithNoMatches = allEdgesWithCounts.compactMap { (edge, count) -> String? in
            if count == 1 {
                return edge
            }
            return nil
        }
        
        let cornerTiles = tiles.filter { $0.edgesForAllFlippages().intersection(Set(edgesWithNoMatches)).count == 2
        }
        
        return cornerTiles.reduce(1) { (result, tile) -> Int in
            return result * tile.number
        }
    }
    
    public func solvePart2(input: [String]) -> Int {
        
        let size = Int(sqrt(Double(input.count)))
        
        var tiles = input.map { tile -> Tile in
            Tile(tileLines: tile.components(separatedBy: "\n"))
        }

        // dont need flipped in x and y as that is the same result as not flipped!
        let allPossibleTilesFlipped = tiles.flatMap { tile in
            return [tile, tile.flipX(), tile.flipY()]
        }
        
        let allEdges = allPossibleTilesFlipped.flatMap { $0.allEdges() }
        var allEdgesWithCounts = [String: Int]()
        
        allEdges.forEach { edge in
            let value = allEdgesWithCounts[edge] ?? 0
            allEdgesWithCounts[edge] = (value + 1)
        }
        
        let edgesWithNoMatches = Set(allEdgesWithCounts.compactMap { (edge, count) -> String? in
            if count == 1 {
                return edge
            }
            return nil
        })
        
        var corners = [Tile]()
        var edges = [Tile]()
        tiles.forEach { tile in
            if tile.edgesForAllFlippages().intersection(edgesWithNoMatches).count == 2 {
                if Set(tile.allEdges()).intersection(edgesWithNoMatches).count == 2 {
                    corners.append(tile)
                }
                if Set(tile.flipX().allEdges()).intersection(edgesWithNoMatches).count == 2 {
                    corners.append(tile.flipX())
                }
                if Set(tile.flipY().allEdges()).intersection(edgesWithNoMatches).count == 2 {
                    corners.append(tile.flipY())
                }
                if Set(tile.flipY().flipX().allEdges()).intersection(edgesWithNoMatches).count == 2 {
                    corners.append(tile.flipY().flipX())
                }
            }
            
            if tile.edgesForAllFlippages().intersection(edgesWithNoMatches).count == 1 {
                if Set(tile.allEdges()).intersection(edgesWithNoMatches).count == 1 {
                    edges.append(tile)
                }
                if Set(tile.flipX().allEdges()).intersection(edgesWithNoMatches).count == 1 {
                    edges.append(tile.flipX())
                }
                if Set(tile.flipY().allEdges()).intersection(edgesWithNoMatches).count == 1 {
                    edges.append(tile.flipY())
                }
            }
        }
        
        var topLeft = corners.first!
        var grid: [Position: Tile] = [:]
        while !Set([topLeft.edge(.top), topLeft.edge(.left)]).isSubset(of: edgesWithNoMatches) {
            topLeft = topLeft.rotateRight()
        }
        
        corners.remove(at: indexOf(topLeft, items: corners))
        
        
        return 0
    }
    
    func removeTile(tile: Tile, from tiles: [Tile]) -> [Tile] {
        return tiles.filter { (value) -> Bool in
            value.number != tile.number
        }
    }
    
    func indexOf(_ tile: Tile, items: [Tile]) -> Int {
        for i in 0..<items.count {
            if items[i].number == tile.number {
                return i
            }
        }
        return -1
    }
    
}
