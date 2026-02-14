//
//  AppContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import Foundation

final class UnauthenticatedAppContainer {
    lazy var client: FirestoreClient = FirestoreClientImpl()
    
    @MainActor
    private func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel()
    }
    
    @MainActor
    func makeLoginView() -> some View {
        LogInView(vm: self.makeLoginView())
    }
}
