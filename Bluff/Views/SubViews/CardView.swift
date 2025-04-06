//
//  CardView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 29/03/25.
//

import Foundation
import SwiftUI

struct CardView: View {
    let card: CardDetail
    let isSelected: Bool
    let onTap: () -> Void
    let onDoubleTap: () -> Void  // 👈 New closure
    var Cheight: CGFloat
    var Cwidth: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isSelected ? Color.green.opacity(0.5) : Color.yellow.opacity(0.5)
                )
                .fill(
                    card.isRoundCard ? Color.mint : .clear
                )
                .frame(width: Cwidth, height: Cheight)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(card.swiftUIColor, lineWidth: 2)
                )

            VStack {
                Text(card.rank)
                    .font(.headline)
                    .foregroundColor(card.swiftUIColor)
                Text(card.suit)
                    .font(.largeTitle)
                    .foregroundColor(card.swiftUIColor)
            }
        }
        .onTapGesture {
            onTap()
        }
        .onTapGesture(count: 2) {  // 👈 Double-tap gesture
            onDoubleTap()
        }
    }
}

extension CardDetail {
    var swiftUIColor: Color {
        switch color.lowercased() {
        case "red":
            return .red
        case "black":
            return .black
        default:
            return .gray // fallback or "joker" etc.
        }
    }
}
