//
//  Navigation.swift
//  Bluff
//
//  Created by Divyansh Bhardwaj on 01/04/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
class Router {
    var path = NavigationPath()
    var toJoin = false
    
    func navigateToGame(toJoin: Bool) {
        self.toJoin = toJoin
        path.append(Route.game)
    }
    func navigateToHome() {
        path.append(Route.home)
    }
    func navigateToSetting() {
        path.append(Route.setting)
    }
    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum Route: Hashable {
    case game
    case home
    case setting
}

struct RouterViewModifier: ViewModifier {
    @State private var router = Router()
    private func routeView(for route: Route) -> some View {
        Group {
            switch route {
            case .game:
                GameView(gameStyle: router.toJoin ? .player : .host)
            case .home:
                HomeView()
            case .setting:
                GameView(gameStyle: router.toJoin ? .player : .host)
            }
        }
        .environment(router)
    }
    func body(content: Content) -> some View {
        NavigationStack(path: $router.path) {
            content
                .environment(router)
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
        }
    }
}

extension View {
    public func withRouter() -> some View {
        modifier(RouterViewModifier())
    }
}
