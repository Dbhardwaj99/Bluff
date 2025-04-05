//
//  GameView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: NewGameViewModel = NewGameViewModel()
    @State var seededCard = CardDetail(rank: "1", suit: "😜", color: .blue, isSelected: false, status: .notPlayed)
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(Array(gameViewModel.gameData.cardDetails.filter { key, value in
                switch key {
                case .player1, .player2, .player3, .player4, .player5, .player6:
                    return !value.isEmpty
                default:
                    return false
                }
            }), id: \.0) { key, value in // Use `.0` as the ID (key of the tuple)
                HStack {
                    Text("\(displayName(for: key))")
                    Spacer()
                    Text("\(value.count) cards")
                }
                .background(.white)
            }
            
            Text(gameViewModel.isPlayerTurn ? "Your Turn" : "AI is playing...")
                .font(.title)
                .bold()
                .frame(height: 50)
            
            VStack{
                let thrownCards = gameViewModel.gameData.cardDetails[.inStash] ?? []

                if thrownCards.isEmpty {
                    Text("No thrown cards yet")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                        .frame(height: 300)
                } else {
                    StaggeredGrid(
                        columns: 4,
                        spacing: 10,
                        items: thrownCards
                    ) { item in
                        CardView(card: item,
                                 isSelected: item.isSelected,
                                 isHighlighted: item.isSelected,
                                 onTap: {},
                                 Cheight: 210,
                                 Cwidth: 140
                        )
                    }
                    .frame(height: 300)
                    .padding()
                }
            }
            
            ZStack{
                if let playerCards = gameViewModel.gameData.cardDetails[.player1] {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(playerCards, id: \.id) { item in
                                GeometryReader { geometry in
                                    CardView(card: item,
                                             isSelected: item.isSelected,
                                             isHighlighted: item.isSelected,
                                             onTap: {
                                        gameViewModel.handleCardTap(item: item)
                                    },
                                             Cheight: 210,
                                             Cwidth: 140
                                    )
                                    .rotation3DEffect(
                                        Angle(
                                            degrees: Double((geometry.frame(in: .global).minX - 20) / 100)
                                        ),
                                        axis: (x: 0, y: 1, z: 0),
                                        anchor: .center,
                                        anchorZ: 0.0,
                                        perspective: 0.5
                                    )
                                }
                                .containerRelativeFrame(
                                    .horizontal,
                                    count: 2,
                                    spacing: 1
                                )
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .scaleEffect(x: phase.isIdentity ? 1.0 : 0.3,
                                                     y: phase.isIdentity ? 1.0 : 0.3)
                                        .offset(y: phase.isIdentity ? 0 : 50)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(16, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 300)
                    .padding()
                }
                Button(action: {
//                    gameViewModel.playTurn()
                }) {
                    Circle()
                        .fill(.yellow.shadow(.drop(color: .black, radius: 10)))
//                        .fill(.yellow.shadow(.inner(color: .black, radius: 10)))
                        .frame(width: 200, height: 200)
                        .frame(width: 130, height: 50)
                        .overlay(content: {
                            Text(gameViewModel.isPlayerTurn ? "Play Turn" : "Check Cards")
                                .foregroundStyle(.white)
                        })
                }
                .offset(y: 100)
                .disabled(!gameViewModel.isPlayerTurn)
            }
        }
        .background(.gray)
    }
    
    func displayName(for status: cardStatus) -> String {
        switch status {
        case .player1: return "Player 1"
        case .player2: return "Player 2"
        case .player3: return "Player 3"
        case .player4: return "Player 4"
        case .player5: return "Player 5"
        case .player6: return "Player 6"
        default: return ""
        }
    }
}

#Preview {
    GameView()
}


import SwiftUI

struct Parallax_ScrollView: View {
    let imageNames = ["building 1", "building 2", "building 3", "building 4", "building 5", "building 6", "building 7"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< 5) { item in
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 30)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)), Color(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .rotation3DEffect(
                                Angle(
                                    degrees: Double((geometry.frame(in: .global).minX - 20) / -20)
                                ),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .center,
                                anchorZ: 0.0,
                                perspective: 1
                            )
                    }
                    .frame(width: 300, height: 300)
                }
            }
            .padding()
        }
    }
}
