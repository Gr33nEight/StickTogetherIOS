//
//  RootRouterModifier.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

struct RootRouterModifier: ViewModifier {
    @Binding var path: [Route]
    func body(content: Content) -> some View {
        content
            .environment(\.navigate) { type in
                switch type {
                case .push(let route):
                    path.append(route)
                case .unwind(let route):
                    guard let route else {
                        path.removeAll()
                        return
                    }
                    guard let index = path.firstIndex(where: {$0 == route}) else { return }
                    path = Array(path.prefix(upTo: index + 1))
                }
            }
    }
}

extension View {
    func rootRouter(path: Binding<[Route]>) -> some View {
        self.modifier(RootRouterModifier(path: path))
    }
}
