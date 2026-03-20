//
//  TransactionFactory.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 20/03/2026.
//

import Foundation

protocol TransactionFactory {
    func run(
        _ block: @escaping (TransactionContext) throws -> Void
    ) async throws
}


