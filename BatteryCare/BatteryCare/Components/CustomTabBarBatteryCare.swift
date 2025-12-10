import SwiftUI

struct CustomTabBarBatteryCare: View {
    @Binding var selectedTab: TabBatteryCare
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(TabBatteryCare.allCases, id: \.rawValue) { tab in
                TabBarItemBatteryCare(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        CustomTabBarBatteryCare(selectedTab: .constant(.tab1))
    }
}

