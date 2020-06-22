//
//  Game.swift
//

import Foundation

public protocol GameDelegate: class {
    func game(_ gane: Game, updatedValue value: GameCellValue, at position: GamePosition)
    func game(_ game: Game, gameFinishedWithCondition condition: GameFinishCondition)
    func game(_ game: Game, turnChangedTo turn: GameTurn)
}

public enum GameCellValue {
    case empty
    case cross
    case circle
}

public enum GameTurn {
    case cross
    case circle
    
    func gameCellValue() -> GameCellValue {
        switch self {
            case .cross: return .cross
            case .circle: return .circle
        }
    }
}

public enum GamePositionRow: CaseIterable {
    case top
    case middle
    case bottom
}

public enum GamePositionColumn: CaseIterable {
    case left
    case middle
    case right
}

public struct GamePosition: Hashable {
    var row: GamePositionRow
    var column: GamePositionColumn
    
    init(_ row: GamePositionRow, _ column: GamePositionColumn) {
        self.row = row
        self.column = column
    }
}

public enum GameFinishCondition {
    case crossWon
    case circleWon
    case tie
}

public class Game {
    public weak var delegate: GameDelegate?
    
    private var cells: Dictionary<GamePosition, GameCellValue> = Dictionary()

    public private(set) var currentTurnValue: GameTurn = .cross {
        didSet {
            self.delegate?.game(self, turnChangedTo: currentTurnValue)
        }
    }
    
    private let winningSequences: [[GamePosition]] = [
        // horizontal conditions
        [GamePosition(.top, .left), GamePosition(.top, .middle), GamePosition(.top, .right)],
        [GamePosition(.middle, .left), GamePosition(.middle, .middle), GamePosition(.middle, .right)],
        [GamePosition(.bottom, .left), GamePosition(.bottom, .middle), GamePosition(.bottom, .right)],
        // vertical conditions
        [GamePosition(.top, .left), GamePosition(.middle, .left), GamePosition(.bottom, .left)],
        [GamePosition(.top, .middle), GamePosition(.middle, .middle), GamePosition(.bottom, .middle)],
        [GamePosition(.top, .right), GamePosition(.middle, .right), GamePosition(.bottom, .right)],
        // diagonals
        [GamePosition(.top, .left), GamePosition(.middle, .middle), GamePosition(.bottom, .right)],
        [GamePosition(.top, .right), GamePosition(.middle, .middle), GamePosition(.bottom, .left)]
    ]
    
    public init() {
        self.reset()
    }
    
    // clear board and restart
    public func reset() {
        for row in GamePositionRow.allCases {
            for column in GamePositionColumn.allCases {
                let position = GamePosition(row, column)
                setValueUnsafe(.empty, at: position)
            }
        }
        self.currentTurnValue = .cross
    }

    // available positions to play
    public func emptyPositions() -> [GamePosition] {
        return cells.filter({ $0.value == .empty }).map { (tuple) -> GamePosition in
            let (position, _) = tuple
            return position
        }
    }
    
    // current player plays at a position
    public func play(at position: GamePosition) {
        guard self.cells[position] == .empty,
            isGameFinished() == nil else {
            return
        }
        setValueUnsafe(self.currentTurnValue.gameCellValue(), at: position)
        
        if let condition = isGameFinished() {
            self.delegate?.game(self, gameFinishedWithCondition: condition)
        } else {
            self.currentTurnValue = self.currentTurnValue == .cross ? .circle : .cross
        }
    }
    
    public func value(at position: GamePosition) -> GameCellValue {
        return cells[position]!    // we know for sure there is a value in the position, really want to avoid an optional here
    }
    
    // just set a cell value and fire the delegate, don't check anyting else
    private func setValueUnsafe(_ value: GameCellValue, at position: GamePosition) {
        cells[position] = value
        self.delegate?.game(self, updatedValue: value, at: position)
    }

    // if game can finish, return finish condition (either some player can win or there is a tie with no more empty cells)
    public func isGameFinished() -> GameFinishCondition? {
        
        // ceck for geme ending condition
        for sequence in self.winningSequences {
            let allValues = Set(sequence.map({ self.value(at: $0) }))
            if allValues.count == 1 {
                // this means they were all equal, so there is a winner
                if let value = allValues.first,
                    value != .empty {
                    if case .circle = value {
                        return .circleWon
                    } else if case .cross = value {
                        return .crossWon
                    }
                }
            }
        }
        
        // check for tie
        if self.emptyPositions().count == 0 {
            return .tie
        }
        
        return nil
    }
}
