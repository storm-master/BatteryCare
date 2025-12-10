import SwiftUI

struct LoadingViewBatteryCare: View {
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("logoBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                Spacer()
                Image("loading_imageBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .scaleEffect(isPulsing ? 1.15 : 0.9)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear {
                        isPulsing = true
                    }
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea(.all)
        LoadingViewBatteryCare()
    }
}

