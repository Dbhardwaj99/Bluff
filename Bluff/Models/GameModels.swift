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
    
    init(rank: String, suit: String, color: String, isSelected: Bool, status: CardStatus) {
        self.id = UUID()
        self.rank = rank
        self.suit = suit
        self.color = color
        self.isSelected = isSelected
        self.status = status
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

struct GameData: Codable {
    var playerDeck: [CardDetail] {
        didSet {
            updateCardDetails()
        }
    }
    var allPlayers: [Player]
    var currentPlayer: Player
    var currentStash: [Player: [CardDetail]]?
    var cardDetails: [CardStatus: [CardDetail]] = [:]
    
    mutating func updateCardDetails() {
        cardDetails = Dictionary(grouping: playerDeck, by: { $0.status })
    }
}

//struct GameData{
//    var playerDeck: [CardDetail] {
//        didSet {
//            updateCardDetails()
//        }
//    }
//    var allPlayers: [Player]
//    var currentPlayer: Player
//    var currentStash: [Player: [CardDetail]]
//    
//    var cardDetails: [cardStatus: [CardDetail]] = [:]
//    
//    init() {
//        self.allPlayers = [
//            Player.player1,
//            Player.player2,
//            Player.player3
//        ]
//        
//        self.currentPlayer = allPlayers[0]
//        self.currentStash = [:]
//        
//        var deck: [CardDetail] = []
//        let cardData: [String: [String]] = [
//            "♠️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
//            "♥️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
//            "♦️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
//            "♣️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
//            "🃏": ["Joker", "Joker", "Joker"]
//        ]
//        
//        for (suit, ranks) in cardData {
//            for rank in ranks {
//                let color: Color = (suit == "♥️" || suit == "♦️") ? .red : .black
//                deck.append(CardDetail(rank: rank, suit: suit, color: color, isSelected: false, status: .notPlayed))
//            }
//        }
//        
//        deck.shuffle()
//        
//        for (index, _) in deck.enumerated() {
//            switch index % 3 {
//            case 0: deck[index].status = .player1
//            case 1: deck[index].status = .player2
//            case 2: deck[index].status = .player3
//            default: break
//            }
//        }
//        
//        self.playerDeck = deck
//        self.updateCardDetails()
//        print("Player 1 cards: \(cardDetails[.player1] ?? [])\nPlayer 2 cards: \(cardDetails[.player2] ?? [])\nPlayer 3 cards: \(cardDetails[.player3] ?? [])")
//    }
//    
//    mutating func updateCardDetails() {
//        cardDetails = Dictionary(grouping: playerDeck, by: { $0.status })
//    }
//}


//enum PlayerDeck: CaseIterable {
//    case player1, player2, player3, player4
//}
