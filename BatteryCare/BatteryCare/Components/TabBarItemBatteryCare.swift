import SwiftUI

struct TabBarItemBatteryCare: View {
    let tab: TabBatteryCare
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(tab.iconName)
                .resizable()
                .scaledToFit()
                .frame(height: 81)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                        .frame(width: 73,height: 75)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        HStack {
            TabBarItemBatteryCare(tab: .tab1, isSelected: true) {}
            TabBarItemBatteryCare(tab: .tab2, isSelected: false) {}
        }
    }
}

