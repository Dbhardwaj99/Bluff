//
//  ContentView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 27/03/25.
//

import SwiftUI

import SwiftUI

// MARK: - Model for a Playing Card
struct CardDetail: Identifiable, Equatable {
    let id = UUID()
    let rank: String
    let suit: String
    let color: Color
    var isSelected: Bool
    
    mutating func toggleSelection() {
        isSelected.toggle()
    }
}

// MARK: - Dictionary for Card Ranks and Suits
let cardData: [String: [String]] = [
    "♠️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
    "♥️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
    "♦️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
    "♣️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
    "🃏": ["Joker", "Joker"] // Two Jokers
]


enum Player: String, CaseIterable {
    case player1 = "Player 1"
    case player2 = "Player 2"
    case player3 = "Player 3"
    case player4 = "Player 4"
}

// MARK: - Generate & Shuffle the Deck
func generateShuffledDeck() -> [CardDetail] {
    var deck: [CardDetail] = []
    
    for (suit, ranks) in cardData {
        for rank in ranks {
            let color: Color = (suit == "♥️" || suit == "♦️") ? .red : .black
            deck
                .append(
                    CardDetail(
                        rank: rank,
                        suit: suit,
                        color: color,
                        isSelected: false
                    )
                )
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



//for (player, deck) in playerDecks {
//    print("\(player.rawValue)'s deck: \(deck.count) cards")
//}
//

// MARK: - Card View
struct CardView: View {
    let card: CardDetail
    let isSelected: Bool
    let isHighlighted: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isHighlighted ? Color.green.opacity(0.5) : (isSelected ? Color.yellow.opacity(0.5) : card.color.opacity(0.2)))
                .frame(width: 70, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(card.color, lineWidth: 2)
                )

            VStack {
                Text(card.rank)
                    .font(.headline)
                    .foregroundColor(card.color)
                Text(card.suit)
                    .font(.largeTitle)
                    .foregroundColor(card.color)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

enum PlayerDeck: CaseIterable {
    case player1, player2, player3, player4
}

// MARK: - ContentView
struct ContentView: View {
    @State private var selectedCard: CardDetail?
    @State private var playedCards: [CardDetail] = []
    @State private var isPlayerTurn = true
    @State private var highlightedCard: CardDetail?
    @State private var currentPlayer: PlayerDeck = .player1
    @State var isSelected : Bool = false
    @State private var currentDeck: [CardDetail] = distributeCards()[.player1] ?? []
    let playerDecks = distributeCards()
    
    var body: some View {
        VStack(alignment: .center) {
            Text(isPlayerTurn ? "Your Turn" : "AI is playing...")
                .font(.title)
                .bold()
                .frame(height: 50)
            
            VStack{
                Text("Your cards")
                StaggeredGrid(columns: 4, spacing: 10, items: currentDeck) { item in
                    CardView(card: item,
                             isSelected: item.isSelected,
                             isHighlighted: item.isSelected,
                             onTap: {
                        if let index = currentDeck.firstIndex(where: { $0.id == item.id }) {
                            currentDeck[index].isSelected.toggle()
                            selectedCard = currentDeck[index]
                        }
                    })
                }
                .frame(height: 300)
                .padding()
            }
            .background(.gray)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(playedCards.prefix(18), id: \.id) { item in
                        CardView(card: item, isSelected: selectedCard == item, isHighlighted: false) {
                            if isPlayerTurn {
                                selectedCard = item
                            }
                        }
                    }
                }
            }
            .frame(height: 120)
            .padding()
//            List(currentDeck) { card in
//                CardView(
//                    card: card,
//                    isSelected: isSelected,
//                    isHighlighted: isSelected,
//                    onTap: {
//                        selectedCard = card
//                        isSelected = true
//                    }
//                )
//                Text("\(card.rank) \(card.suit)")
//                    .foregroundColor(card.color)
//            }.foregroundStyle(.red)
//                .listStyle(.sidebar)
            
            Button(isPlayerTurn ? "Play Turn" : "Check Cards") {
                playTurn()
            }
            .disabled(!isPlayerTurn)
            .padding()
            
//            Button("Next Player") {
//                changeDeck()
//            }
        }
    }
    
    func playTurn() {
        guard let selectedCard = selectedCard else { return }
        isSelected = false
        isPlayerTurn = false
        playedCards.append(selectedCard)
        
        currentDeck.removeAll { $0 == selectedCard }
        
        changeDeck()
        playAISequence(newPlayedCards: currentDeck, remainingMoves: 3)
    }
    
    func changeDeck() {
        switch currentPlayer {
        case .player1:
            currentPlayer = .player2
        case .player2:
            currentPlayer = .player3
        case .player3:
            currentPlayer = .player4
        case .player4:
            currentPlayer = .player1
        }
        
        currentDeck = playerDecks[currentPlayer] ?? []
    }
    
    func playAISequence(newPlayedCards: [CardDetail], remainingMoves: Int) {
        guard remainingMoves > 0 else {
            playedCards = newPlayedCards
            isPlayerTurn = true
            selectedCard = nil
            return
        }
        
        if let aiCard = currentDeck.filter({ !newPlayedCards.contains($0) }).randomElement() {
            highlightedCard = aiCard
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                var updatedPlayedCards = newPlayedCards
                updatedPlayedCards.append(aiCard)
                
                currentDeck.removeAll { $0 == aiCard }
                highlightedCard = nil
                
                playAISequence(newPlayedCards: updatedPlayedCards, remainingMoves: remainingMoves - 1)
            }
        } else {
            playedCards = newPlayedCards
            isPlayerTurn = true
            selectedCard = nil
        }
        changeDeck()
    }
}



#Preview {
    ContentView()
}
