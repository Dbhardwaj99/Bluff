//
//  GameViewController.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var cardData: [String: [String]] = [
        "♠️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        "♥️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        "♦️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        "♣️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        "🃏": ["Joker", "Joker", "Joker"] // Two Jokers
    ]

    @Published var currentSelectedCard: [CardDetail] = []
    @Published var currentThrownCards: [CardDetail] = []
    
    @Published var isPlayerTurn = true
    @Published var currentPlayer: PlayerDeck = .player1
    
    @Published var decks: [PlayerDeck: [CardDetail]] = [:]

    // Computed property for the current player's deck
    var playDeck: [CardDetail] {
        return decks[.player1] ?? []
    }

    init() {
        let distributedDecks = distributeCards()
        self.decks = distributedDecks
    }

    func generateShuffledDeck() -> [CardDetail] {
        var deck: [CardDetail] = []
        
        for (suit, ranks) in cardData {
            for rank in ranks {
                let color: Color = (suit == "♥️" || suit == "♦️") ? .red : .black
                deck.append(CardDetail(rank: rank, suit: suit, color: color, isSelected: false))
            }
        }
        
        return deck.shuffled()
    }

    func distributeCards() -> [PlayerDeck: [CardDetail]] {
        let shuffledDeck = generateShuffledDeck()
        var playerDecks: [PlayerDeck: [CardDetail]] = [:]
        let allPlayers = PlayerDeck.allCases
        
        for (index, player) in allPlayers.enumerated() {
            let start = index * 13
            let end = start + 13
            playerDecks[player] = Array(shuffledDeck[start..<end])
        }
        
        return playerDecks
    }

    func handleCardTap(item: CardDetail) {
        guard isPlayerTurn else { return }
        
        // Find the index in the current player's deck
        guard let playerDeckIndex = decks[currentPlayer]?.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Toggle selection in the player's deck
        decks[currentPlayer]?[playerDeckIndex].isSelected.toggle()
        
        // Manage currentSelectedCard array
        if let selectedIndex = currentSelectedCard.firstIndex(where: { $0.id == item.id }) {
            currentSelectedCard.remove(at: selectedIndex)
        } else {
            currentSelectedCard.append(decks[currentPlayer]![playerDeckIndex])
        }
    }

    func playTurn() {
        guard isPlayerTurn, !currentSelectedCard.isEmpty else { return }
        
        // Add selected cards to thrown cards
        currentThrownCards.append(contentsOf: currentSelectedCard)
        
        // Remove selected cards from player's deck
        decks[currentPlayer]?.removeAll { currentSelectedCard.contains($0) }
        
        // Reset selection
        currentSelectedCard.removeAll()
        
        // Switch to AI turn
        isPlayerTurn = false
        
        // Start AI play sequence
        playAISequence(lastPlayedCards: currentThrownCards, remainingMoves: 3)
    }

    func playAISequence(lastPlayedCards: [CardDetail], remainingMoves: Int) {
        guard !isPlayerTurn, remainingMoves > 0 else {
            endAITurn()
            return
        }

        // Move to next AI player
        changeDeck()

        // AI card selection logic
        if let aiCard = selectAICard(lastPlayedCards: lastPlayedCards) {
            // Simulate AI thinking and playing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                
                // Add AI's card to thrown pile
                self.currentThrownCards.append(aiCard)
                
                // Remove the card from AI's deck
                self.decks[self.currentPlayer]?.removeAll { $0.id == aiCard.id }
                
                // Continue AI sequence or end turn
                self.playAISequence(lastPlayedCards: self.currentThrownCards, remainingMoves: remainingMoves - 1)
            }
        } else {
            // No valid move for AI
            endAITurn()
        }
    }

    private func selectAICard(lastPlayedCards: [CardDetail]) -> CardDetail? {
        guard let lastCard = lastPlayedCards.last else {
            return decks[currentPlayer]?.randomElement()
        }

        // Prioritize matching rank
        if let matchingCard = decks[currentPlayer]?.first(where: { $0.rank == lastCard.rank }) {
            return matchingCard
        }

        // If no matching rank, return a random card
        return decks[currentPlayer]?.randomElement()
    }

    private func changeDeck() {
        switch currentPlayer {
        case .player1: currentPlayer = .player2
        case .player2: currentPlayer = .player3
        case .player3: currentPlayer = .player4
        case .player4: currentPlayer = .player1
        }
    }

    private func endAITurn() {
        // Switch back to player's turn
        isPlayerTurn = true
        currentPlayer = .player1
        
        // Reset selection
        currentSelectedCard.removeAll()
    }

    func getPlayerCardCounts() -> [Int] {
        return PlayerDeck.allCases.map { decks[$0]?.count ?? 0 }
    }
}
