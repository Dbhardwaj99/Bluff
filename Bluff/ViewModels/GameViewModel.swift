//
//  GameViewController.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import Foundation
import SwiftUI
import Combine
import SocketIO

class NewGameViewModel: ObservableObject {
    @Published var gameData: GameData
   
    private var gameId: String = ""
    private var hasJoinedGame = false
    let gameStyle : GameStyle
    var assignedPlayer: Player
    @Published var callBluff: Bool = false {
        didSet {
            if callBluff {
                checkBluff()
            }
        }
    }
    var assignedPlayerStatus: CardStatus {
        CardStatus(rawValue: assignedPlayer.rawValue) ?? .notPlayed
    }
    
    init(gameStyle: GameStyle) {
        self.gameStyle = gameStyle
        self.gameData = GameData(
            playerDeck: [],
            allPlayers: [],
            currentPlayer: .player1
        )
        self.assignedPlayer = .player1
        self.gameId = generateRoomCode()
        
        if gameStyle == .host{
            initialiseGame()
        }else{
            joinGame(gameId: "LOUAX")
        }
    }
   
    
    func generateRoomCode(length: Int = 5) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
//    func joinGame(){
//        
//    }
//    
//    func joinGame(gameId: String) {
//        self.gameId = gameId
//
//        FirebaseManager.shared.observeGameData(gameId: gameId) { [weak self] newData in
//            DispatchQueue.main.async {
//                // Add player if needed
//                if !(newData.allPlayers.contains(player)) {
//                    var updatedData = newData
//                    updatedData.allPlayers.append(player)
//                    FirebaseManager.shared.saveGameData(gameData: updatedData, gameId: gameId)
//                }
//                self?.gameData = newData
//            }
//        }
//    }
    
    func joinGame(gameId: String) {
        FirebaseManager.shared.observeGameData(gameId: gameId) { [weak self] newData in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard var updatedData = newData else {
                    print("Failed to load game data.")
                    return
                }

                // Avoid re-joining
                if self.hasJoinedGame {
                    self.gameData = updatedData
                    return
                }

                if updatedData.allPlayers.count >= 6 {
                    print("Game is full. Cannot join.")
                    return
                }

                // Assign next available player
                let usedPlayers = updatedData.allPlayers
                let availablePlayer = Player.allCases.first(where: { !usedPlayers.contains($0) })

                guard let assignedPlayer = availablePlayer else {
                    print("No available player slots!")
                    return
                }

                updatedData.allPlayers.append(assignedPlayer)

                // Redistribute cards
                let totalPlayers = updatedData.allPlayers.count
                for index in updatedData.playerDeck.indices {
                    let player = updatedData.allPlayers[index % totalPlayers]
                    updatedData.playerDeck[index].status = self.cardStatus(for: player)
                }

                updatedData.updateCardDetails()

                self.gameData = updatedData
                self.gameId = gameId
                self.assignedPlayer = assignedPlayer
                self.hasJoinedGame = true // ✅ prevent loop

                FirebaseManager.shared.saveGameData(gameData: updatedData, gameId: gameId)
            }
        }
    }
    
    func initialiseGame(){
        // Setup players
        let allPlayers: [Player] = [.player1]

        // Generate and shuffle deck
        var deck: [CardDetail] = []
        let cardData: [String: [String]] = [
            "♠️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
            "♥️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
            "♦️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
            "♣️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
            "🃏": ["Joker", "Joker", "Joker"]
        ]
        for (suit, ranks) in cardData {
            for rank in ranks {
                let color = (suit == "♥️" || suit == "♦️") ? "red" : "black"
                deck.append(CardDetail(rank: rank, suit: suit, color: color, isSelected: false, status: .notPlayed))
            }
        }

        deck.shuffle()
        
//        This needs to be fixed
        for index in deck.indices {
            deck[index].status = .player1
        }

        let currentStash: [Player: [CardDetail]] = [:]

        // Create initial gameData
        var gameData = GameData(
            playerDeck: deck,
            allPlayers: allPlayers,
            currentPlayer: allPlayers[0],
            currentStash: currentStash
        )
        gameData.updateCardDetails()
        self.gameData = gameData

        // ✅ Save to Firebase
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)

        // 🔁 Optional: start observing if host needs real-time updates too
        observeGame()
    }
    
    func observeGame() {
        FirebaseManager.shared.observeGameData(gameId: gameId) { [weak self] fetchedData in
            guard let self = self, let data = fetchedData else { return }
            var newData = data
            newData.updateCardDetails()
            DispatchQueue.main.async {
                self.gameData = newData
            }
        }
    }
    
    func saveGame() {
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)
    }
    
    var isPlayerTurn: Bool {
        return gameData.currentPlayer == assignedPlayer
    }
    
    
    func updateCurrentStash(_ toUpdate: [CardDetail]) {
        var stash = gameData.currentStash ?? [:] // get or create new dictionary
        stash[gameData.currentPlayer] = toUpdate
        gameData.currentStash = stash // assign back

        // Send updated stash to the server
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)
    }
    
    func checkBluff() {
        guard let lastPlayer = gameData.allPlayers.last else { return }
        guard let stash = gameData.currentStash?[lastPlayer], let firstCard = stash.first else { return }

        let allMatch = stash.allSatisfy { $0.rank == firstCard.rank }

        if allMatch {
            // Transfer stash to last player
            print("✅ Bluff was honest! Cards go to \(lastPlayer)")
        } else {
            // Handle bluff penalty
            print("❌ Bluff failed! Penalty should be applied to \(lastPlayer)")
        }
    }
    
    func startPolling() {
        // Poll server for game updates
    }
    
    func pass() {
        if let currentIndex = gameData.allPlayers.firstIndex(of: gameData.currentPlayer) {
            let nextIndex = (currentIndex + 1) % gameData.allPlayers.count
            gameData.currentPlayer = gameData.allPlayers[nextIndex]
            saveGame()
        }
    }
    
    func handleCardTap(item: CardDetail) {
        guard isPlayerTurn else { return }
        
        guard let playerDeckIndex = gameData.cardDetails[.player1]?.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        gameData.cardDetails[.player1]?[playerDeckIndex].isSelected.toggle()
    }
    
    func playTurn() {
        guard isPlayerTurn else { return }

        // 1. Get selected cards
        guard !gameData.playerDeck.filter({ $0.status == assignedPlayerStatus && $0.isSelected }).isEmpty else {
            print("⚠️ No cards selected.")
            return
        }

        // 2. Update selected cards
        gameData.playerDeck = gameData.playerDeck.map { card in
            var updated = card
            if updated.status == assignedPlayerStatus && updated.isSelected {
                updated.status = .inStash
                updated.isSelected = false
            }
            return updated
        }

        // 3. Refresh grouped card details
        gameData.updateCardDetails()

        // 4. Advance turn
        if let currentIndex = gameData.allPlayers.firstIndex(of: gameData.currentPlayer) {
            let nextIndex = (currentIndex + 1) % gameData.allPlayers.count
            gameData.currentPlayer = gameData.allPlayers[nextIndex]
        }

        // 5. Sync with Firebase
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)

        print("✅ Turn played and data synced.")
    }
    
    func cardStatus(for player: Player) -> CardStatus {
        switch player {
        case .player1: return .player1
        case .player2: return .player2
        case .player3: return .player3
        case .player4: return .player4
        case .player5: return .player5
        case .player6: return .player6
        }
    }
}
