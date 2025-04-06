//
//  GameModels.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import Foundation
import SwiftUI

struct CardDetail: Identifiable, Equatable, Codable {
    let id: UUID
    let rank: String
    let suit: String
    let color: String  // Represent color as "red" or "black"
    var isSelected: Bool
    var status: CardStatus
    var isRoundCard:Bool
    
    init(
        rank: String,
        suit: String,
        color: String,
        isSelected: Bool,
        status: CardStatus,
        isRoundCard: Bool
    ) {
        self.id = UUID()
        self.rank = rank
        self.suit = suit
        self.color = color
        self.isSelected = isSelected
        self.status = status
        self.isRoundCard = isRoundCard
    }
}

enum CardStatus: String, Codable {
    case notPlayed
    case inStash
    case flushed
    case player1
    case player2
    case player3
    case player4
    case player5
    case player6
}

enum Player: String, CaseIterable, Codable {
    case player1 = "Player 1"
    case player2 = "Player 2"
    case player3 = "Player 3"
    case player4 = "Player 4"
    case player5 = "Player 5"
    case player6 = "Player 6"
}

struct Stash: Codable {
    var currentStashCards: [Player: [CardDetail]] = [:]
    var roundCard: CardDetail?
    var lastPlayer: Player? // 👈 Add this
}

struct GameData: Codable {
    var playerDeck: [CardDetail] {
        didSet {
            updateCardDetails()
        }
    }
    var allPlayers: [Player]
    var gameStatus: GameStatus? = .notStarted
    var currentPlayer: Player
    var currentStash: Stash?
    var cardDetails: [CardStatus: [CardDetail]] = [:]
    
    mutating func updateCardDetails() {
        cardDetails = Dictionary(grouping: playerDeck, by: { $0.status })
    }
}
