import SwiftUI

@main
struct MigraNoteApp: App {
    @StateObject private var store = AttackStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .tint(Color(red: 0.49, green: 0.36, blue: 0.84))
        }
    }
}
