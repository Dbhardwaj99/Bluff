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
    @Published var alreadyCardSelected = false
    @Published var callBluff: Bool = false {
        didSet {
            if callBluff {
                checkBluff()
            }
        }
    }
   
    private var gameId: String = ""
    var hasJoinedGame = false
    
    let gameStyle : GameStyle
    
    var assignedPlayer: Player
    var assignedPlayerStatus: CardStatus {
        CardStatus(rawValue: assignedPlayer.rawValue) ?? .notPlayed
    }
    var isPlayerTurn: Bool {
        return gameData.currentPlayer == assignedPlayer
    }

    init(gameStyle: GameStyle) {
        self.gameStyle = gameStyle
        self.gameData = GameData(
            playerDeck: [],
            allPlayers: [],
 gameStatus: .notStarted,
            currentPlayer: .player1,
            currentStash: Stash(
                currentStashCards: [:]
            )
        )
        self.assignedPlayer = .player1
        self.gameId = generateRoomCode()
        
        if gameStyle == .host{
            initialiseGame()
        }else{
//            joinGame(gameId: "LOUAX")
        }
    }
}

// MARK: - UI interactions
extension NewGameViewModel{
    func handleDoubleTap(item: CardDetail) {
        guard isPlayerTurn else { return }

        if alreadyCardSelected {
            for i in gameData.playerDeck.indices {
                    gameData.playerDeck[i].isRoundCard = false
            }
        }

        guard let index = gameData.playerDeck.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        gameData.playerDeck[index].isRoundCard = true
        gameData.playerDeck[index].isSelected.toggle()
        alreadyCardSelected = true

        gameData.updateCardDetails()
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
    
    func pass() {
        if let currentIndex = gameData.allPlayers.firstIndex(of: gameData.currentPlayer) {
            let nextIndex = (currentIndex + 1) % gameData.allPlayers.count
            gameData.currentPlayer = gameData.allPlayers[nextIndex]
            saveGame()
        }
    }

    func playTurn(with bluffCard: CardDetail? = nil) {
        guard isPlayerTurn else {
            print("⚠️ Not your turn.")
            return
        }

        // Get selected cards from playerDeck
        let selectedCards = gameData.playerDeck.filter { $0.isSelected }

        guard !selectedCards.isEmpty else {
            print("⚠️ No cards selected.")
            return
        }

        if gameData.currentStash?.currentStashCards.isEmpty ?? true {
            // First turn of the round
            guard let bluffCard = bluffCard else {
                print("⚠️ No bluff card selected.")
                return
            }

            // Create new stash
            var newStash = Stash(currentStashCards: [:], roundCard: bluffCard)
            newStash.currentStashCards[gameData.currentPlayer] = selectedCards
            newStash.lastPlayer = gameData.currentPlayer
            gameData.currentStash = newStash

            print("🂠 Starting round with bluff card: \(bluffCard.rank) \(bluffCard.suit)")
        } else {
            // Continuing stash
            gameData.currentStash?.currentStashCards[gameData.currentPlayer] = selectedCards
            gameData.currentStash?.lastPlayer = gameData.currentPlayer
        }

        // Update selected card status in playerDeck (no appending, just status change)
        gameData.playerDeck = gameData.playerDeck.map { card in
            if selectedCards.contains(where: { $0.id == card.id }) {
                var updated = card
                updated.status = .inStash
                updated.isSelected = false
                return updated
            } else {
                return card
            }
        }

        // Turn rotation
        if let currentIndex = gameData.allPlayers.firstIndex(of: gameData.currentPlayer) {
            let nextIndex = (currentIndex + 1) % gameData.allPlayers.count
            gameData.currentPlayer = gameData.allPlayers[nextIndex]
        }

        // Save
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)

        print("✅ \(selectedCards.count) cards played by \(gameData.currentPlayer.previous(in: gameData.allPlayers) ?? gameData.currentPlayer)")
    }
    // TODO: Fix Logic
    func checkBluff() {
        guard gameData.currentStash?.lastPlayer != gameData.currentPlayer else {
            print("⚠️ Can't call bluff on yourself")
            return
        }
            
        
        guard let roundCard = gameData.currentStash?.roundCard else {
            print("⚠️ No round card found.")
            return
        }

        guard let currentStashCards = gameData.currentStash?.currentStashCards else {
            print("⚠️ No stash found.")
            return
        }

        let allStashCards = currentStashCards.flatMap { $0.value }
        
        guard let lastPlayer = gameData.currentStash?.lastPlayer,
              let playedCards = gameData.currentStash?.currentStashCards[lastPlayer] else {
            print("⚠️ No last player or played cards found.")
            return
        }

        let allMatch = playedCards.allSatisfy { $0.rank == roundCard.rank }

        let newStatus = allMatch ? gameData.currentPlayer : lastPlayer

        // Update statuses in playerDeck
        gameData.playerDeck = gameData.playerDeck.map { card in
            if allStashCards.contains(where: { $0.id == card.id }) {
                var updatedCard = card
                updatedCard.status = getCorrectStatus(player: newStatus)
                print("Updated correct status")
                return updatedCard
            } else {
                print("updated wrong status")
                return card
            }
        }

        if allMatch {
            print("✅ Bluff was honest! \(gameData.currentPlayer) wrongly accused.")
        } else {
            print("❌ Bluff failed! \(lastPlayer) was bluffing.")
            gameData.currentPlayer = lastPlayer
        }
        gameData.updateCardDetails()

        // Clear the stash
        gameData.currentStash = Stash(
            currentStashCards: [:],
            roundCard: nil,
            lastPlayer: nil
        )

        // No need to call updateCardDetails(), it’s triggered by playerDeck.didSet
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)
    }
    
    func getCorrectStatus(player: Player) -> CardStatus {
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

// MARK: - Room Logic
extension NewGameViewModel{
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
            currentStash: Stash(currentStashCards: currentStash)
        )
        gameData.updateCardDetails()
        self.gameData = gameData

        // ✅ Save to Firebase
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)

        // 🔁 Optional: start observing if host needs real-time updates too
        observeGame()
    }
}

// MARK: - Helper Functions
extension NewGameViewModel {
    func updateCurrentStash(_ toUpdate: [CardDetail]) {
        // Check if currentStash exists; if not, create a new one
        if gameData.currentStash == nil {
            gameData.currentStash = Stash()
        }

        // Safely unwrap and update the currentStashCards
        gameData.currentStash?.currentStashCards[gameData.currentPlayer] = toUpdate

        // Save to Firebase
        FirebaseManager.shared.saveGameData(gameData: gameData, gameId: gameId)
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
    
    
    func generateRoomCode(length: Int = 5) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}

extension Player: Equatable {
    func previous(in players: [Player]) -> Player? {
        guard let index = players.firstIndex(of: self) else { return nil }
        return index == 0 ? players.last : players[index - 1]
    }
}
