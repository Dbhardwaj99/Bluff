//
//  GameModels.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 28/03/25.
//

import Foundation
import SwiftUI

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

enum Player: String, CaseIterable {
    case player1 = "Player 1"
    case player2 = "Player 2"
    case player3 = "Player 3"
    case player4 = "Player 4"
}

enum PlayerDeck: CaseIterable {
    case player1, player2, player3, player4
}
