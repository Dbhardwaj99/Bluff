//
//  StaggeredGrid.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 27/03/25.
//

import Foundation
import SwiftUI

struct StaggeredGrid: View {
    var content: (CardDetail) -> AnyView
    var items: [CardDetail]
    var columns: Int
    var spacing: CGFloat
    
    // Precompute columns to avoid re-filtering on every update.
    private var columnItems: [[CardDetail]] {
        var result = Array(repeating: [CardDetail](), count: columns)
        for (index, item) in items.enumerated() {
            result[index % columns].append(item)
        }
        return result
    }
    
    init(columns: Int = 2,
         spacing: CGFloat = 10,
         items: [CardDetail],
         @ViewBuilder content: @escaping (CardDetail) -> some View) {
        self.items = items
        self.columns = columns
        self.spacing = spacing
        self.content = { AnyView(content($0)) }
    }
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(0..<columns, id: \.self) { column in
                    LazyVStack(spacing: spacing) {
                        ForEach(columnItems[column]) { item in
                            content(item)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
