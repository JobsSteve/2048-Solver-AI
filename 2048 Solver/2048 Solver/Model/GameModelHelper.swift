//
//  GameModelHelper.swift
//  2048 Solver
//
//  Created by Honghao Zhang on 3/18/15.
//  Copyright (c) 2015 Honghao Zhang. All rights reserved.
//

import Foundation

struct GameModelHelper {
    
    static func gameBoardEmptySpotsCount(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Int {
        let dimension = gameBoard.dimension
        var result = 0
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    result += 1
                case .Number:
                    break
                }
            }
        }
        return result
    }
    
    /**
    Return a list of tuples describing the coordinates of empty spots remaining on the gameboard.
    
    :returns: coordinates for empty spots
    */
    static func gameBoardEmptySpots(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> [(Int, Int)] {
        let dimension = gameBoard.dimension
        var buffer = Array<(Int, Int)>()
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    buffer += [(i, j)]
                case .Number:
                    break
                }
            }
        }
        return buffer
    }
    
    /**
    Get whether game board is full
    
    :returns: true is game board is full
    */
    static func gameBoardFull(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        return gameBoardEmptySpots(&gameBoard).count == 0
    }
    
    static func isGameEnded(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> Bool {
        let dimension = gameBoard.dimension
        if !gameBoardFull(&gameBoard) {
            return false
        }
        
        // Copy a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = copyGameBoard(&gameBoard)
        
        // Perform and check
        var resultActions = [Action1D]()
        for i in 0 ..< dimension {
            // UP
            var upMoveTilePointers = tempGameBoard.getColumn(i, reversed: true)
            let (upMoveActions, _) = processOneDimensionTiles(&upMoveTilePointers)
            resultActions.extend(upMoveActions)
            
            // Left
            var leftMoveTilePointers = tempGameBoard.getRow(i, reversed: true)
            let (leftMoveActions, _) = processOneDimensionTiles(&leftMoveTilePointers)
            resultActions.extend(leftMoveActions)
        }
        
        // Dealloc temp memory
        deallocGameBoard(&tempGameBoard)
        
        if resultActions.count == 0 {
            return true
        } else {
            return false
        }
    }
}

extension GameModelHelper {
    static func allocInitGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                gameBoard[i, j].initialize(Tile.Empty)
            }
        }
    }
    
    static func allocInitGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, withGameBoard intGameBoard: [[Int]]) {
        let dimension = gameBoard.dimension
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                if intGameBoard[i][j] == 0 {
                    gameBoard[i, j].initialize(Tile.Empty)
                } else {
                    gameBoard[i, j].initialize(Tile.Number(intGameBoard[i][j]))
                }
            }
        }
    }
    
    static func emptyGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].memory = Tile.Empty
            }
        }
    }
    
    static func deallocGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        let dimension = gameBoard.dimension
        // Dealloc temp memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                gameBoard[i, j].destroy()
                gameBoard[i, j].dealloc(1)
            }
        }
    }
    
    static func copyGameBoard(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> SquareGameBoard<UnsafeMutablePointer<Tile>> {
        let dimension = gameBoard.dimension
        // Init a temp game board
        var tempGameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>> = SquareGameBoard(dimension: dimension, initialValue: nil)
        // Alloc memory
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                tempGameBoard[i, j] = UnsafeMutablePointer<Tile>.alloc(1)
                switch gameBoard[i, j].memory {
                case .Empty:
                    tempGameBoard[i, j].initialize(Tile.Empty)
                case let .Number(tileNumber):
                    tempGameBoard[i, j].initialize(gameBoard[i, j].memory)
                }
            }
        }
        
        return tempGameBoard
    }
}

// MARK: Game Logic
extension GameModelHelper {
    
    static func performInsertCommand(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> InitAction {
        let (initNumber, insertedCoordinate) = insertTileAtRandomLocation(&gameBoard)
        return InitAction(actionType: .Init, initCoordinate: insertedCoordinate, initNumber: initNumber)
    }
    
    static func performMoveCommand(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, moveCommand: MoveCommand) -> ([MoveAction], Int) {
        let dimension = gameBoard.dimension
        var resultMoveActions = [MoveAction]()
        var increasedScore: Int = 0
        switch moveCommand.direction {
        case .Up:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (dimension - 1 - $0, i) })
                    let toCoordinate = (dimension - 1 - action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Down:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getColumn(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ ($0, i) })
                    let toCoordinate = (action.toIndex, i)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Left:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: true)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, dimension - 1 - $0) })
                    let toCoordinate = (i, dimension - 1 - action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        case .Right:
            for i in 0 ..< dimension {
                var tilePointers = gameBoard.getRow(i, reversed: false)
                let (actions, score) = processOneDimensionTiles(&tilePointers)
                for action in actions {
                    let fromCoordinates = action.fromIndexs.map({ (i, $0) })
                    let toCoordinate = (i, action.toIndex)
                    resultMoveActions.append(MoveAction(actionType: .Move, fromCoordinates: fromCoordinates, toCoordinate: toCoordinate))
                }
                increasedScore += score
            }
        }
        
        return (resultMoveActions, increasedScore)
    }
}

// MARK: Game Logic Helper
extension GameModelHelper {
    // MARK: Move and Merge
    /**
    Process a list of tiles, for a 2048 board game, commands with any directions will eventually go into an one dimension array whihc can be processed in same way
    
    :param: tiles a list of tile pointers
    
    :returns: result 1D actions
    */
    static func processOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var (actions, increasedScore) = mergeOneDimensionTiles(&tiles)
        actions.extend(condenseOneDimensionTiles(&tiles))
        return (actions, increasedScore)
    }
    
    /**
    Merge a list of Tiles to right
    E.g. [2,2,4,4] -> [_,_,4,8], [4,2,2,2] -> [_,4,2,4]
    More detailed examples:
    [2,2,2,_] -> [2,2,_,2] -> [2,_,_,4] -> [_,_,2,4] (Move leave it as an empty tile)
    [2,_,2,2] -> [2,_,2,2] -> [2,_,0,4] -> [_,2,0,4] -> [_,_,2,4] (Merge creates 0 tile)
    [_,4,2,2] -> [_,4,2,2] -> [_,4,0,4] -> [_,4,0,4] -> [_,_,4,4] (Last step is condense, not include in this method)
    [4,2,_,2,_] -> [4,2,_,_,2] -> [4,0,_,_,4] -(condense)-> [_,_,_,4,4]
    Note: Tiles will be mutated
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: Return a list of actions
    */
    static func mergeOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> ([Action1D], Int) {
        var resultActions = [Action1D]()
        var increasedScore: Int = 0
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].memory {
            case .Empty:
                continue
            case let .Number(tileNumber):
                // Right most tile
                if i == count - 1 {
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [2,_,_] -> [_,_,2]
                        tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                        tiles[i].memory = Tile.Empty
                        resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if tileNumber == rightTileNumber {
                            // Merge
                            tiles[rightIndex].memory = Tile.Number(tileNumber * 2)
                            increasedScore += tileNumber * 2
                            tiles[i].memory = Tile.Number(0)
                            resultActions.append(Action1D(fromIndexs: [i, rightIndex], toIndex: rightIndex))
                        } else if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    }
                }
            }
        }
        
        return (resultActions, increasedScore)
    }
    
    /**
    Condense tiles, remove .Empty tiles and .0 tiles, and generate associated Actions
    E.g. [_,2,_,2] -> [_,_,2,2]
    [0,2,_,_] -> [_,_,_,2]
    
    :param: tiles the reference of an array of references of Tiles
    
    :returns: a list of actions
    */
    static func condenseOneDimensionTiles(inout tiles: [UnsafeMutablePointer<Tile>]) -> [Action1D] {
        var resultActions = [Action1D]()
        let count = tiles.count
        for i in stride(from: count - 1, to: -1, by: -1) {
            switch tiles[i].memory {
            case .Empty:
                continue
            case let .Number(tileNumber):
                if tileNumber == 0 {
                    tiles[i].memory = Tile.Empty
                    continue
                } else {
                    let (rightTile, rightIndex) = getFirstRightNonEmptyTileForIndex(i, inTiles: tiles)
                    switch rightTile {
                    case .Empty:
                        // Right wall
                        // [_,_,4] -> [_,_,4]
                        // [2,_,_] -> [_,_,2]
                        if rightIndex > i + 1 {
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    case let .Number(rightTileNumber):
                        // Exist rightTile
                        if rightIndex > i + 1 {
                            // Move
                            tiles[rightIndex - 1].memory = Tile.Number(tileNumber)
                            tiles[i].memory = Tile.Empty
                            resultActions.append(Action1D(fromIndexs: [i], toIndex: rightIndex - 1))
                        }
                    }
                }
            }
        }
        
        return resultActions
    }
    
    /**
    Get the first valid right tile
    E.g. tiles: [_,4,_,2,_]
    1
    return 3
    
    :param: index current index
    :param: tiles an array of tiles
    
    :returns: (rightTile, rightIndex), if there's no right vaild tile, return .Empty
    */
    static func getFirstRightNonEmptyTileForIndex(index: Int, inTiles tiles: [UnsafeMutablePointer<Tile>]) -> (Tile, Int) {
        let count = tiles.count
        for i in (index + 1) ..< count {
            switch tiles[i].memory {
            case .Empty:
                continue
            case .Number:
                return (tiles[i].memory, i)
            }
        }
        return (Tile.Empty, count)
    }
    
    // MARK: Insert
    
    static func insertTileAtRandomLocation(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) -> (Int, (Int, Int)) {
        let seed = Int(arc4random_uniform(UInt32(100)))
        let initNumber: Int = seed < 15 ? 4 : 2
        let insertedCoordinate = insertTileAtRandomLocation(&gameBoard, value: initNumber)
        return (initNumber, insertedCoordinate)
    }
    
    /**
    Insert a tile with a given value at a random open position upon the game board.
    
    :param: value new number value to be inserted
    
    :returns: inserted coordinate, if game board is full, return (-1, -1)
    */
    static func insertTileAtRandomLocation(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, value: Int) -> (Int, Int) {
        let openSpots = gameBoardEmptySpots(&gameBoard)
        if openSpots.count == 0 {
            // No more open spots; don't even bother
            return (-1, -1)
        }
        // Randomly select an open spot, and put a new tile there
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile(&gameBoard, pos: (x, y), value: value)
        return (x, y)
    }
    
    /**
    Insert a tile with a given value at a position upon the game board.
    
    :param: pos   insert position/ coordinate
    :param: value new inserted value
    */
    static func insertTile(inout gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>, pos: (Int, Int), value: Int) {
        let (x, y) = pos
        switch gameBoard[x, y].memory {
        case .Empty:
            gameBoard[x, y].memory = Tile.Number(value)
        case .Number:
            break
        }
    }
}

// MARK: Debug Helper
extension GameModelHelper {
    static func printOutGameBoard(gameBoard: SquareGameBoard<UnsafeMutablePointer<Tile>>) {
        println("Game Board:")
        let dimension = gameBoard.dimension
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameBoard[i, j].memory {
                case .Empty:
                    print("_\t")
                case let .Number(num):
                    print("\(num)\t")
                }
            }
            println()
        }
    }
    
    static func printOutTilePointers(tilePointers: [UnsafeMutablePointer<Tile>]) {
        println("Tile Pointers:")
        for p in tilePointers {
            switch p.memory {
            case .Empty:
                print("_\t")
            case let .Number(num):
                print("\(num)\t")
            }
        }
        println()
    }
    
    static func printOutCommand(command: MoveCommand) {
        switch command.direction {
        case .Up:
            logDebug("Up")
        case .Down:
            logDebug("Down")
        case .Left:
            logDebug("Left")
        case .Right:
            logDebug("Right")
        }
    }
    
    static func printOutMoveActions(actions: [MoveAction]) {
        for action in actions {
            println("From: \(action.fromCoordinates) To:\(action.toCoordinate)")
        }
    }
}

extension GameModelHelper {
    static func fullCommands(shuffle: Bool = false) -> [MoveCommand] {
        var commands = [MoveCommand]()
        commands.append(MoveCommand(direction: MoveDirection.Up))
        commands.append(MoveCommand(direction: MoveDirection.Left))
        commands.append(MoveCommand(direction: MoveDirection.Down))
        commands.append(MoveCommand(direction: MoveDirection.Right))
        
        if shuffle {
            commands.shuffle()
        }
        return commands
    }
}
