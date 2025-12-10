import SwiftUI

struct MainTabViewBatteryCare: View {
    @State private var selectedTab: TabBatteryCare = .tab1
    
    var body: some View {
        ZStack {
            Image("background_mainBatteryCare")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Group {
                    switch selectedTab {
                    case .tab1:
                        Tab1ContentViewBatteryCare()
                    case .tab2:
                        Tab2ContentViewBatteryCare()
                    case .tab3:
                        Tab3ContentViewBatteryCare()
                    case .tab4:
                        Tab4ContentViewBatteryCare()
                    }
                }
                Spacer()
                CustomTabBarBatteryCare(selectedTab: $selectedTab)
                    .padding(.bottom, 4)
            }
        }
    }
}

#Preview {
    MainTabViewBatteryCare()
}

