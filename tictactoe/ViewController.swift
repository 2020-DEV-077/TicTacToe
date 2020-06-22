//
//  ViewController.swift
//  tictactoe
//
//  Created by Marco Mustapic on 19/06/2020.
//  Copyright © 2020 Marco Mustapic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var buttonForGamePosition: Dictionary<GamePosition, UIButton> = Dictionary()
    
    private let game = Game()
    
    private var nextTurnLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create view that will contain board
        let boardView = UIView(frame: .zero)
        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.backgroundColor = .lightGray
        self.view.addSubview(boardView)
        boardView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0, constant: -40.0).isActive = true
        boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 1.0).isActive = true
        boardView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        boardView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
 
        // next turn label
        let nextTurnLabel = UILabel(frame: .zero)
        nextTurnLabel.translatesAutoresizingMaskIntoConstraints = false
        nextTurnLabel.textColor = .black
        nextTurnLabel.accessibilityValue = "turn"
        self.view.addSubview(nextTurnLabel)
        nextTurnLabel.bottomAnchor.constraint(equalTo: boardView.topAnchor, constant: -10.0).isActive = true
        nextTurnLabel.leftAnchor.constraint(equalTo: boardView.leftAnchor).isActive = true
        self.nextTurnLabel = nextTurnLabel

        // stack view with rows
        let boardRows = UIStackView()
        boardRows.translatesAutoresizingMaskIntoConstraints = false
        boardRows.axis = .vertical
        boardRows.alignment = .fill
        boardRows.distribution = .fillEqually
        boardRows.spacing = 10.0
        boardView.addSubview(boardRows)
        boardRows.leftAnchor.constraint(equalTo: boardView.leftAnchor).isActive = true
        boardRows.rightAnchor.constraint(equalTo: boardView.rightAnchor).isActive = true
        boardRows.topAnchor.constraint(equalTo: boardView.topAnchor).isActive = true
        boardRows.bottomAnchor.constraint(equalTo: boardView.bottomAnchor).isActive = true

        // board buttons
        GamePositionRow.allCases.forEach { (row) in
            let boardRow = createGameRow(row: row)
            boardRows.addArrangedSubview(boardRow)
        }

        // start game
        self.game.delegate = self
        self.game.reset()
    }

    // find position for button and play
    @objc private func gameButtonTapped(_ sender: UIButton) {
        for (position, button) in self.buttonForGamePosition {
            if button == sender {
                self.game.play(at: position)
            }
        }
    }
    
    private func createGameButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(gameButtonTapped(_:)), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }

    private func createGameRowButtons(row: GamePositionRow) -> [(UIButton, GamePosition)] {
        return GamePositionColumn.allCases.map { (column) -> (UIButton, GamePosition) in
            let button = createGameButton()
            let position = GamePosition(row, column)
            button.accessibilityValue = "\(row.stringValue())_\(column.stringValue())"
            return (button, position)
        }
    }

    private func createGameRow(row: GamePositionRow) -> UIStackView {
        let buttonsAnsPositions = createGameRowButtons(row: row)

        let boardRow = UIStackView()
        boardRow.translatesAutoresizingMaskIntoConstraints = false
        boardRow.axis = .horizontal
        boardRow.alignment = .fill
        boardRow.distribution = .fillEqually
        boardRow.spacing = 10.0
        
        buttonsAnsPositions.forEach { (tuple) in
            let (button, position) = tuple
            self.buttonForGamePosition[position] = button
            boardRow.addArrangedSubview(button)
        }
        
        return boardRow
    }
}

extension ViewController: GameDelegate {
    func game(_ gane: Game, updatedValue value: GameCellValue, at position: GamePosition) {
        guard let button = self.buttonForGamePosition[position] else {
            return
        }
        let text: String
        switch value {
            case .empty: text = ""
            case .circle: text = "O"
            case .cross: text = "X"
        }
        button.setTitle(text, for: .normal)
    }
    
    func game(_ game: Game, gameFinishedWithCondition condition: GameFinishCondition) {
        let message: String
        switch condition {
            case .circleWon: message = "Circle won"
            case .crossWon: message = "Cross won"
            case .tie: message = "Tie"
        }
        let controller = UIAlertController(title: "Game finishhed!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.game.reset()
        }
        controller.addAction(okAction)
        self.present(controller, animated: true)
    }
    
    func game(_ game: Game, turnChangedTo turn: GameTurn) {
        let text: String
        switch turn {
            case .cross: text = "Current player: X"
            case .circle: text = "Current player: O"
        }
        self.nextTurnLabel.text = text
    }
    
    
}

extension GamePositionRow {
    func stringValue() -> String {
        switch (self) {
            case .top: return "top"
            case .middle: return "middle"
            case .bottom: return "bottom"
        }
    }
}

extension GamePositionColumn {
    func stringValue() -> String {
        switch (self) {
            case .left: return "left"
            case .middle: return "middle"
            case .right: return "right"
        }
    }
}
