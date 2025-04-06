//
//  GameView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import SwiftUI

enum GameStyle {
    case host
    case player
}

struct GameView: View {
    @State var gameStyle: GameStyle
    @ObservedObject var gameViewModel: NewGameViewModel
    @State var enteredRoomCode: String = ""
    
    init(
        gameStyle: GameStyle
    ) {
        self.gameStyle = gameStyle
        self.gameViewModel = NewGameViewModel(
            gameStyle: gameStyle
        )
    }
    
    @State var seededCard = CardDetail(
        rank: "1",
        suit: "😜",
        color: "red",
        isSelected: false,
        status: .notPlayed,
        isRoundCard: true
    )
    
    var body: some View {
        ZStack{
            VStack(alignment: .center) {
                HStack {
                    Text("Players: \(gameViewModel.gameData.allPlayers.count)/6")
                    Spacer()
                    Text("Turn: \(gameViewModel.gameData.currentPlayer.rawValue.capitalized)")
                }
                .font(.caption)
                .padding()
                .background(.ultraThinMaterial)
                .frame(height: 50)
                
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
                    .frame(height: 10)
                }
                
                Text(gameViewModel.isPlayerTurn ? "Your Turn" : "AI is playing...")
                    .font(.title)
                    .bold()
                    .frame(height: 20)
                
                VStack{
                    let thrownCards = gameViewModel.gameData.cardDetails[.inStash] ?? []
                    
                    if thrownCards.isEmpty {
                        Text("No thrown cards yet")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                            .frame(height: 200)
                    } else {
                        StaggeredGrid(
                            columns: 6,
                            spacing: 10,
                            items: thrownCards
                        ) { item in
                            CardView(card: item,
                                     isSelected: item.isSelected,
//                                     isHighlighted: item.isSelected,
                                     onTap: {}, onDoubleTap: {},
                                     Cheight: 60,
                                     Cwidth: 40
                            )
                        }
                        .frame(height: 200)
                        .padding()
                    }
                }
                
                VStack{
                    if let playerCards = gameViewModel.gameData.cardDetails[getCorrectStatus(player: gameViewModel.assignedPlayer)] {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(playerCards, id: \.id) { item in
                                    GeometryReader { geometry in
                                        CardView(
card: item,
                                                 isSelected: item.isSelected,
//                                                 isHighlighted: item.isSelected,
                                                 onTap: {
                                            gameViewModel.handleCardTap(item: item)
                                        },
                                                 onDoubleTap : {
                                            gameViewModel.handleCardTap(item: item)
                                            gameViewModel
                                                         .handleDoubleTap(
                                                            item: item
                                                         )
                                        },
                                                 Cheight: 150,
                                                 Cwidth: 100
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
                        .frame(height: 200)
                        .padding()
                    }
                    HStack{
                        Button(action: {
                            if gameViewModel.isPlayerTurn{
                                gameViewModel.playTurn()
                            }else{
                                gameViewModel.checkBluff()
                            }
                        }) {
                            Rectangle()
                                .fill(gameViewModel.isPlayerTurn ? .yellow: .red)
                                .frame(width: 280, height: 100)
                                .overlay(content: {
                                    Text(gameViewModel.isPlayerTurn ? "Play Turn" : "Check Cards")
                                        .foregroundStyle(.white)
                                })
                        }
//                        .offset(y: 100)
//                        .disabled(!gameViewModel.isPlayerTurn)
                        
                        Spacer()
                        
                        Button(action: {
                            gameViewModel.pass()
                        }) {
                            Rectangle()
                                .fill(
                                    .purple
                                        .shadow(
                                            .drop(color: .black, radius: 10)
                                        )
                                )
                                .frame(width: 130, height: 100)
                                .overlay(content: {
                                    Text(gameViewModel.isPlayerTurn ? "Pass" : "Check Stats")
                                        .foregroundStyle(.white)
                                })
                        }
//                        .offset(y: 100)
                        .disabled(!gameViewModel.isPlayerTurn)
                        
                    }
                }
            }
            .background(.gray)
            .blur(radius: gameViewModel.gameData.gameStatus == .notStarted ? 5 : 0)
            
            if gameViewModel.gameData.gameStatus == .notStarted {
                VStack(spacing: 24) {
                    if gameViewModel.gameStyle == .host {
                        Text("Start game")
                            .font(.largeTitle)
                            .foregroundStyle(.blue)
                        
                        Button(action: {
                            gameViewModel.gameData.gameStatus = .ongoing
                            gameViewModel.saveGame()
                        }) {
                            Text("Start Game")
                                .font(.headline)
                                .frame(width: 130, height: 50)
                                .background(.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                                .shadow(radius: 8)
                        }
                    } else {
                        Text("Join a Room")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        TextField("Enter Room Code", text: $enteredRoomCode)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(.white.opacity(0.9)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                            )
                            .padding(.horizontal)

                        Button(action: {
                            gameViewModel.joinGame(gameId: enteredRoomCode)
                        }) {
                            Text("Join Game")
                                .font(.headline)
                                .frame(width: 130, height: 50)
                                .background(.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 8)
                        }
                    }
                }
                .padding()
                .frame(width: 300, height: 300)
                .foregroundStyle(.yellow)
            }
        }
    }
    
    func displayName(for status: CardStatus) -> String {
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

#Preview {
    GameView(gameStyle: .host)
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
