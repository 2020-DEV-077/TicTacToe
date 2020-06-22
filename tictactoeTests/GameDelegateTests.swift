//
//  GameDelegateTests.swift
//

import XCTest
@testable import tictactoe

class GameDelegateTests: XCTestCase {

    func testGameDelegate_updateAndTurnChange() {
        
        let game = Game()
        let expectedEvents: [TestGameDelegateEvent] = [
            .updated(.empty, GamePosition(.top, .left)), .updated(.empty, GamePosition(.top, .middle)), .updated(.empty, GamePosition(.top, .right)),
            .updated(.empty, GamePosition(.middle, .left)), .updated(.empty, GamePosition(.middle, .middle)), .updated(.empty, GamePosition(.middle, .right)),
            .updated(.empty, GamePosition(.bottom, .left)), .updated(.empty, GamePosition(.bottom, .middle)), .updated(.empty, GamePosition(.bottom, .right)),
            .turnChanged(.cross)
        ]
        let delegate = TestGameDelegate(expectation: expectation(description: "init events called"), expectedEventCount: expectedEvents.count)
        game.delegate = delegate
        game.reset()
        
        waitForExpectations(timeout: 0.2) { error in
            if let _ = error {
                XCTFail("Delegate not called")
            }
            // use sets because we don't care about the order really
            let expectedEventsSet = Set(expectedEvents)
            let actualEventsSet = Set(delegate.events)
            XCTAssertEqual(expectedEventsSet, actualEventsSet)
        }
    }

    func testGameDelegate_won() {
        
        let game = Game()
        let expectedEvents: [TestGameDelegateEvent] = [
            .updated(.cross, GamePosition(.top, .left)),
            .turnChanged(.circle),
            .updated(.circle, GamePosition(.top, .middle)),
            .turnChanged(GameTurn.cross),
            .updated(.cross, GamePosition(.middle, .left)),
            .turnChanged(GameTurn.circle),
            .updated(.circle, GamePosition(.middle, .middle)),
            .turnChanged(GameTurn.cross),
            .updated(.cross, GamePosition(.bottom, .left)),
            .finished(.crossWon),
        ]
        let delegate = TestGameDelegate(expectation: expectation(description: "init events called"), expectedEventCount: expectedEvents.count)
        game.reset()
        game.delegate = delegate    // delegate after init
        
        game.play(at: GamePosition(.top, .left))
        game.play(at: GamePosition(.top, .middle))
        game.play(at: GamePosition(.middle, .left))
        game.play(at: GamePosition(.middle, .middle))
        game.play(at: GamePosition(.bottom, .left))

        waitForExpectations(timeout: 0.2) { error in
            if let _ = error {
                XCTFail("Delegate not called")
            }
            XCTAssertEqual(expectedEvents, delegate.events)
        }
    }

}

// record events and later can compare them with expected ones
class TestGameDelegate: GameDelegate {
    
    private let expectation: XCTestExpectation
    var eventCount = 0
    private let expectedEventCount: Int
    var events: [TestGameDelegateEvent] = []
    
    init(expectation: XCTestExpectation, expectedEventCount: Int) {
        self.expectation = expectation
        self.expectedEventCount = expectedEventCount
    }
    
    func game(_ gane: Game, updatedValue value: GameCellValue, at position: GamePosition) {
        self.eventArrived(event: .updated(value, position))
    }
    
    func game(_ game: Game, gameFinishedWithCondition condition: GameFinishCondition) {
        self.eventArrived(event: .finished(condition))
    }
    
    func game(_ game: Game, turnChangedTo turn: GameTurn) {
        self.eventArrived(event: .turnChanged(turn))
    }
    
    private func eventArrived(event: TestGameDelegateEvent) {
        self.events.append(event)
        self.eventCount += 1
        if self.eventCount == self.expectedEventCount {
            expectation.fulfill()
        }
    }
}

enum TestGameDelegateEvent: Equatable, Hashable {
    case updated(GameCellValue, GamePosition)
    case finished(GameFinishCondition)
    case turnChanged(GameTurn)
}

