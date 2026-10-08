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
    lazy private var userRepository: UserRepository = UserRepositoryImpl(firestoreClient: firestoreClient)

    lazy private var observeSession: ObserveSessionUseCase = ObserveSessionUseCaseImpl(repository: authRepository)
    lazy private var getUser: GetUserUseCase = GetUserUseCaseImpl(userRepository: userRepository)
    lazy private var signOut: SignOutUseCase = SignOutUseCaseImpl(repository: authRepository)

    @MainActor
    lazy var sessionViewModel = SessionViewModel(
        observeSession: observeSession,
        getUser: getUser,
        signOut: signOut
    )
    
    @MainActor
    func makeAppEntry() -> some View {
        AppEntryTemp(viewModel: self.sessionViewModel)
    }
}
