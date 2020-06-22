//
//  GameTests.swift
//

import XCTest
@testable import tictactoe

class GameTests: XCTestCase {

    func testGameInit() {
        
        let game = Game()
        // check that all positions are empty
        for row in GamePositionRow.allCases {
            for column in GamePositionColumn.allCases {
                XCTAssertEqual(game.value(at: GamePosition(row, column)), .empty)
            }
        }
        XCTAssertEqual(game.currentTurnValue, .cross)
    }

    func testGameEmptyPositions() {
        let game = Game()
        
        var expected = Set<GamePosition>()
        for row in GamePositionRow.allCases {
            for column in GamePositionColumn.allCases {
                expected.insert(GamePosition(row, column))
            }
        }
        
        var positionsToRemove = [
            GamePosition(.top, .left),
            GamePosition(.top, .middle),
            GamePosition(.middle, .middle),
            GamePosition(.middle, .right),
        ]
        
        while (positionsToRemove.count > 0) {
            let actual = Set<GamePosition>(game.emptyPositions())
            XCTAssertEqual(actual, expected)
            if let any = positionsToRemove.first {
                game.play(at: any)
                expected.remove(any)
                positionsToRemove.removeAll { $0 == any }
            }
        }
    }

    func testGameSetValue_TurnTaking() {

        let game = Game()
        XCTAssertEqual(game.emptyPositions().count, 9)
        XCTAssertEqual(game.currentTurnValue, .cross)
        
        game.play(at: GamePosition(.top, .left))
        XCTAssertEqual(game.emptyPositions().count, 8)
        XCTAssertEqual(game.currentTurnValue, .circle)
        
        game.play(at: GamePosition(.top, .right))
        XCTAssertEqual(game.emptyPositions().count, 7)
        XCTAssertEqual(game.currentTurnValue, .cross)
    }

    func testGameSetValue_InvalidPosition() {

        let game = Game()
        XCTAssertEqual(game.emptyPositions().count, 9)
        XCTAssertEqual(game.currentTurnValue, .cross)
        
        game.play(at: GamePosition(.top, .left))
        XCTAssertEqual(game.emptyPositions().count, 8)
        XCTAssertEqual(game.currentTurnValue, .circle)
        
        game.play(at: GamePosition(.top, .left))
        XCTAssertEqual(game.emptyPositions().count, 8)
        XCTAssertEqual(game.currentTurnValue, .circle)
    }

    func testGameReset() {

        let game = Game()
        game.play(at: GamePosition(.top, .left))
        game.play(at: GamePosition(.top, .right))
        game.reset()
        XCTAssertEqual(game.emptyPositions().count, 9)
        XCTAssertEqual(game.currentTurnValue, .cross)
    }
    
    func testGameIsGameFinished_No() {
        let game = Game()
        XCTAssertNil(game.isGameFinished())
    }

    func testGameIsGameFinished_CircleWon() {
        let game = Game()
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.middle, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .right))
        XCTAssertEqual(game.isGameFinished(), .circleWon)
    }

    func testGameIsGameFinished_CrossWon() {
        let game = Game()
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .right))
        XCTAssertEqual(game.isGameFinished(), .crossWon)
        game.play(at: GamePosition(.bottom, .right))
        XCTAssertEqual(game.isGameFinished(), .crossWon)
    }

    func testGameIsGameFinished_Reset() {
        let game = Game()
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .right))
        XCTAssertEqual(game.isGameFinished(), .crossWon)
        game.reset()
        XCTAssertNil(game.isGameFinished())
    }

    func testGameIsGameFinished_Tie() {
        let game = Game()
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.top, .right))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.middle, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.middle, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.middle, .right))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .middle))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .left))
        XCTAssertNil(game.isGameFinished())
        game.play(at: GamePosition(.bottom, .right))
        XCTAssertEqual(game.isGameFinished(), .tie)
    }
    
    // TODO: test end game configurations conditions (all possible win conditions, tedious)
}
