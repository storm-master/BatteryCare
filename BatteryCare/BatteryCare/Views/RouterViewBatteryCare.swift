import SwiftUI

struct RouterViewBatteryCare: View {
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Image("background_mainBatteryCare")
                .resizable()
                .ignoresSafeArea(.all)
            if isLoading {
                LoadingViewBatteryCare()
                    .transition(.opacity)
            } else {
                MainTabViewBatteryCare()
                    .transition(.opacity)
            }
        }
        .onAppear {
            let loadingTime = Double.random(in: 2.34...5.34)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + loadingTime) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    RouterViewBatteryCare()
}

