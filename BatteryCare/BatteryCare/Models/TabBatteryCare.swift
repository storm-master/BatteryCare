import Foundation

enum TabBatteryCare: Int, CaseIterable {
    case tab1 = 0
    case tab2 = 1
    case tab3 = 2
    case tab4 = 3
    
    var iconName: String {
        switch self {
        case .tab1: return "tab1BatteryCare"
        case .tab2: return "tab2BatteryCare"
        case .tab3: return "tab3BatteryCare"
        case .tab4: return "tab4BatteryCare"
        }
    }
}
