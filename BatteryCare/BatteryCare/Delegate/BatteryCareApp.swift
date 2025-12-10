import SwiftUI

@main
struct BatteryCareApp: App {
    var body: some Scene {
        WindowGroup {
            RouterViewBatteryCare()
                .preferredColorScheme(.dark)
        }
    }
}
