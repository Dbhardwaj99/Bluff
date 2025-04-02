//
//  HomeView.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 01/04/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(Router.self) var router
    
    var body: some View {
        VStack{
            Text("Hi Player")
            
            Button(action: {
                router.navigateToGame()
            }) {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundStyle(.green)
                    .frame(width: 130, height: 50)
                    .overlay(content: {
                        Text("Create Room")
                            .foregroundStyle(.white)
                    })
            }
            
            Button(action: {
                router.navigateToGame()
            }) {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundStyle(.green)
                    .frame(width: 130, height: 50)
                    .overlay(content: {
                        Text("Join Room")
                            .foregroundStyle(.white)
                    })
            }
        }
    }
}

#Preview {
    HomeView()
}
