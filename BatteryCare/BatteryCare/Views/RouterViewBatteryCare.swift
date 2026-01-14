import SwiftUI

struct RouterViewBatteryCare: View {
    
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Image("background_mainBatteryCare")
                .resizable()
                .ignoresSafeArea(.all)
            
            LoadingViewBatteryCare()
                .transition(.opacity)
        }
    }
}

#Preview {
    RouterViewBatteryCare()
}

