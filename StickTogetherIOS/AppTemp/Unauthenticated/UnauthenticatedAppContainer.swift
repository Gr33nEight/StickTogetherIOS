//
//  AppContainer.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 14/02/2026.
//

import SwiftUI

final class UnauthenticatedAppContainer {
    private lazy var firestoreClient: FirestoreClient = FirestoreClientImpl()
    private lazy var authClient: AuthClient = AuthClientImpl()
    
    private lazy var authRepository: AuthRepository = AuthRepositoryImpl(authClient: authClient, firestoreClient: firestoreClient)
    
    private lazy var signInUseCase: SignInUseCase = SignInUseCaseImpl(repository: authRepository)
    private lazy var signUpUseCase: SignUpUseCase = SignUpUseCaseImpl(repository: authRepository)
    private lazy var signOutUseCase: SignOutUseCase = SignOutUseCaseImpl(repository: authRepository)
    
    @MainActor
    private func makeAuthViewModel() -> AuthViewModelTemp {
        AuthViewModelTemp(signInUseCase: signInUseCase, signUpUseCase: signUpUseCase, signOutUseCase: signOutUseCase)
    }
    
    @MainActor
    func makeLoginView() -> some View {
        LogInView(vm: self.makeAuthViewModel())
    }
}
