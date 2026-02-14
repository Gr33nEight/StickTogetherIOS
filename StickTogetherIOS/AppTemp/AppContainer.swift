//
//  AppContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

final class AppContainer {
    lazy private var authClient: AuthClient = AuthClientImpl()
    lazy private var firestoreClient: FirestoreClient = FirestoreClientImpl()
    
    lazy private var authRepository: AuthRepository = AuthRepositoryImpl(authClient: authClient, firestoreClient: firestoreClient)
    
    lazy private var observeSession: ObserveSessionUseCase = ObserveSessionUseCaseImpl(repository: authRepository)
    
    @MainActor
    lazy var sessionViewModel = SessionViewModel(observeSession: observeSession)
    
    @MainActor
    func makeAppEntry() -> some View {
        AppEntryTemp(viewModel: self.sessionViewModel)
    }
}
