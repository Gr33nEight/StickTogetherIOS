//
//  HomeViewTemp.swift
//  StickTogetherIOS
//
//  Created by Natanael Jop on 13/02/2026.
//

import SwiftUI

struct HomeViewTemp: View {
    @StateObject var viewModel: HomeViewModel
    @Environment(\.navigate) var navigate
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            }
            
            if !viewModel.isLoading && viewModel.visibleHabits.isEmpty {
                Text("Puste")
            }
            
            if let error = viewModel.error {
                Text(error)
            }
            
            ScrollView {
                VStack {
                    ForEach(viewModel.visibleHabits) { habit in
                        HabitCell(habit: habit, selectedDate: Date(), buddy: nil) {
                            //
                        }
                    }
                }
            }
        }.onAppear {
            viewModel.startListening()
        }
    }
}
