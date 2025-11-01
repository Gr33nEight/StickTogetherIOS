//
//  UIApplicationExtension.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 31/10/2025.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
