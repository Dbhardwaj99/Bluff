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
                             onTap: {},
                             Cheight: 210,
                             Cwidth: 140
                    )
                }
                .frame(height: 300)
                .padding()
            }
            .background(.gray)
            
            ZStack{
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(
                            gameViewModel.playDeck.prefix(18),
                            id: \.id
                        ) { item in
                            
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
                
                Button(action: {
                    gameViewModel.playTurn()
                }) {
                    Circle()
//                        .fill(.yellow.shadow(.drop(color: .black, radius: 10)))
                        .fill(.yellow.shadow(.inner(color: .black, radius: 10)))
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
