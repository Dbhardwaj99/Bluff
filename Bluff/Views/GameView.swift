//
//  GameView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import SwiftUI

struct GameView: View {
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
    GameView()
}
