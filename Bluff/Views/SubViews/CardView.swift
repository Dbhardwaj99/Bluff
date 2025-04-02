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
    let isHighlighted: Bool
    let onTap: () -> Void
    var Cheight: CGFloat
    var Cwidth: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isHighlighted ? Color.green.opacity(0.5) : (isSelected ? Color.yellow.opacity(0.5) : card.color.opacity(0.2)))
                .frame(width: Cwidth, height: Cheight)
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
