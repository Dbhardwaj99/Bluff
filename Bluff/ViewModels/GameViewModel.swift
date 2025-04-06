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

enum GameStatus: String, Codable {
    case notStarted
    case ongoing
    case completed
}

class NewGameViewModel: ObservableObject {
    @Published var gameData: GameData
   
    private var gameId: String = ""
    private var hasJoinedGame = false
    @Published var alreadyCardSelected = false
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
            allPlayers: [], gameStatus: .notStarted,
            currentPlayer: .player1
        )
        self.assignedPlayer = .player1
        self.gameId = generateRoomCode()
        
        if gameStyle == .host{
            initialiseGame()
        }else{
//            joinGame(gameId: "LOUAX")
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
    
    func handleDoubleTap(item: CardDetail) {
        guard isPlayerTurn else { return }

        // If a card is already selected as round card, reset all others
        if alreadyCardSelected {
            for i in gameData.playerDeck.indices {
//                if gameData.playerDeck[i].status == assignedPlayerStatus {
                    gameData.playerDeck[i].isRoundCard = false
//                }
            }
        }

        // Find the index of the tapped card
        guard let index = gameData.playerDeck.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        // Set isRoundCard to true for the tapped card
        gameData.playerDeck[index].isRoundCard = true
        alreadyCardSelected = true

        // Rebuild the cardDetails
        gameData.updateCardDetails()
    }
    
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
                deck
                    .append(
                        CardDetail(
                            rank: rank,
                            suit: suit,
                            color: color,
                            isSelected: false,
                            status: .notPlayed,
                            isRoundCard: false
                        )
                    )
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
            allPlayers: allPlayers, gameStatus: .notStarted,
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

        // Find the index in the main playerDeck
        guard let index = gameData.playerDeck.firstIndex(where: { $0.id == item.id/* && $0.status == assignedPlayerStatus */}) else {
            return
        }

        // Toggle selection
        gameData.playerDeck[index].isSelected.toggle()

        // Rebuild cardDetails
        gameData.updateCardDetails()
    }
    
    func playTurn() {
        guard isPlayerTurn else { return }
        guard alreadyCardSelected else { return }

        // Filter selected cards from player's own deck
        let selectedCards = gameData.playerDeck.filter {
            $0.isSelected
        }

        guard !selectedCards.isEmpty else {
            print("⚠️ No cards selected.")
            return
        }

        // 1. Mark selected cards as inStash and deselect
        for i in gameData.playerDeck.indices {
            if /*gameData.playerDeck[i].status == assignedPlayerStatus &&*/ gameData.playerDeck[i].isSelected {
                gameData.playerDeck[i].status = .inStash
                gameData.playerDeck[i].isSelected = false
            }
        }

        // 2. Update cardDetails
        gameData.updateCardDetails()

        // 3. Advance turn
        if let currentIndex = gameData.allPlayers.firstIndex(of: gameData.currentPlayer) {
            let nextIndex = (currentIndex + 1) % gameData.allPlayers.count
            gameData.currentPlayer = gameData.allPlayers[nextIndex]
        }

        // 4. Save to Firebase
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)

        print("✅ Played turn with \(selectedCards.count) cards.")
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
