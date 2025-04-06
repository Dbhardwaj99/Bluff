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
    @State var showBluffCardSelection = false
    @State private var selectedBluffCard: CardDetail? = nil
    
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
                headerView
                
                infoView
                
                Spacer()
                
                cardArena
                
                myCards
                    
                playerButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black)
            .blur(radius: gameViewModel.gameData.gameStatus == .notStarted ? 5 : 0)
            
            if gameViewModel.gameData.gameStatus == .notStarted {
                lobby
            }
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        HStack (alignment: .center){
            Text("\(gameViewModel.gameData.currentPlayer.rawValue.capitalized) is playing...")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 40)
        .background(gameViewModel.isPlayerTurn ? .green : .red)
        .foregroundStyle(.white)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var infoView: some View {
        VStack{
            ScrollView{
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
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(value.count) cards")
                    }
                    .padding(.horizontal, 20)
                    .foregroundStyle(.white)
                    .frame(height: 10)
                }
            }
        }
        .frame(height: 80)
    }
    
    @ViewBuilder
    var cardArena: some View {
        VStack {
            let thrownCards = gameViewModel.gameData.cardDetails[.inStash] ?? []
            
            if thrownCards.isEmpty {
                Text("No thrown cards yet")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                    .frame(height: 300)
            } else {
                StaggeredGrid(
                    columns: 6,
                    spacing: 10,
                    items: thrownCards
                ) { item in
                    CardView(
                        card: item,
                        isSelected: item.isSelected,
                        onTap: {},
                        onDoubleTap: {},
                        Cheight: 60,
                        Cwidth: 40
                    )
                }
                .frame(height: 300)
                .padding()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color.green)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 5)
        )
    }
    
    @ViewBuilder
    var myCards: some View {
        if let playerCards = gameViewModel.gameData.cardDetails[getCorrectStatus(player: gameViewModel.assignedPlayer)] {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(playerCards, id: \.id) { item in
                        GeometryReader { geometry in
                            CardView(
card: item,
                                     isSelected: item.isSelected,
                                     onTap: {
                                gameViewModel.handleCardTap(item: item)
                            },
                                     onDoubleTap : {
                                gameViewModel
                                             .handleDoubleTap(
                                                item: item
                                             )
                            },
                                     Cheight: 90,
                                     Cwidth: 60
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
                            count: 4,
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
            .frame(height: 120)
            .padding()
        }
    }
    
    @ViewBuilder
    var playerButton: some View {
        HStack {
            Button(action: {
                if gameViewModel.isPlayerTurn {
                    if gameViewModel.gameData.currentStash?.currentStashCards.isEmpty ?? true {
                        showBluffCardSelection = true
                    } else {
                        gameViewModel.playTurn()
                    }
                } else {
                    gameViewModel.checkBluff()
                }
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(gameViewModel.isPlayerTurn ? Color.yellow : Color.red)
                    .shadow(color: .black, radius: 2)
                    .frame(width: 220, height: 100)
                    .overlay {
                        Text(gameViewModel.isPlayerTurn ? "Play Turn" : "Call Bluff")
                            .foregroundStyle(.white)
                    }
            }
            
            Spacer(minLength: 0)
            
            Button(action: {
                gameViewModel.pass()
            }) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.purple.shadow(.drop(color: .black, radius: 2)))
                    .frame(width: 120, height: 100)
                    .overlay {
                        Text(gameViewModel.isPlayerTurn ? "Pass" : "Check Stats")
                            .foregroundStyle(.white)
                    }
            }
            .disabled(!gameViewModel.isPlayerTurn)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showBluffCardSelection, onDismiss: {
            if let card = selectedBluffCard {
                gameViewModel.playTurn(with: card)
            }
        }) {
            BluffCardSelectionView(selectedCard: $selectedBluffCard)
        }
    }
    
    @ViewBuilder
    var lobby: some View {
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
                if !gameViewModel.hasJoinedGame{
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
                } else{
                    Text("Waiting for host to start Game")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .frame(width: 300, height: 300)
        .foregroundStyle(.yellow)
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

struct BluffCardSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCard: CardDetail?

    // Generate full card set once
    private var bluffDeck: [CardDetail] {
        var deck: [CardDetail] = []
        let cardData: [String: [String]] = [
            "♥️": ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"],
        ]

        for (suit, ranks) in cardData {
            for rank in ranks {
                let color = (suit == "♥️" || suit == "♦️") ? "red" : "black"
                deck.append(
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

        return deck
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 12) {
                    ForEach(bluffDeck, id: \.id) { card in
                        CardView(
                            card: card,
                            isSelected: false,
                            onTap: {
                                selectedCard = card
                                dismiss()
                            },
                            onDoubleTap: {},
                            Cheight: 60,
                            Cwidth: 40
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Bluff Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selectedCard = nil
                        dismiss()
                    }
                }
            }
        }
    }
}
