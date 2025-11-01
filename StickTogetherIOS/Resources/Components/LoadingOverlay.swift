import SwiftUI

struct LoadingOverlay: View {
    @EnvironmentObject var loading: LoadingManager

    var body: some View {
        ZStack {
            if loading.isLoading {
                // dim background
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)

                // center loader
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .scaleEffect(1.3)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6).opacity(0.12))
                    )
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.12), value: loading.isLoading)
        .allowsHitTesting(loading.isLoading) // block interactions when loading
    }
}