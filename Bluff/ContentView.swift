//
//  ContentView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 27/03/25.
//

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

enum Player: String, CaseIterable {
    case player1 = "Player 1"
    case player2 = "Player 2"
    case player3 = "Player 3"
    case player4 = "Player 4"
}

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
    @ObservedObject var gameViewModel: GameViewModel = GameViewModel()
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(0..<4) { index in
                HStack {
                    Text("Player \(index + 1)")
                    Spacer()
                    Text("\(gameViewModel.getPlayerCardCounts()[index]) cards")
                }
            }
            
            Text(gameViewModel.isPlayerTurn ? "Your Turn" : "AI is playing...")
                .font(.title)
                .bold()
                .frame(height: 50)
            
            VStack{
                Text("Thrown cards")
                StaggeredGrid(
                    columns: 4,
                    spacing: 10,
                    items: gameViewModel.currentThrownCards
                ) { item in
                    CardView(card: item,
                             isSelected: item.isSelected,
                             isHighlighted: item.isSelected,
                             onTap: {})
                }
                .frame(height: 300)
                .padding()
            }
            .background(.gray)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(
                        gameViewModel.playDeck.prefix(18),
                        id: \.id
                    ) { item in
                        CardView(card: item,
                                 isSelected: item.isSelected,
                                 isHighlighted: item.isSelected,
                                 onTap: {
                            gameViewModel.handleCardTap(item: item)
                        })
                    }
                }
            }
            .frame(height: 120)
            .padding()
            
            Button(gameViewModel.isPlayerTurn ? "Play Turn" : "Check Cards") {
                gameViewModel.playTurn()
            }
            .disabled(!gameViewModel.isPlayerTurn)
            .padding()
        }
    }
}



#Preview {
    ContentView()
}
