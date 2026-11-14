import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Attack.timestamp, order: .reverse) private var attacks: [Attack]
    @State private var selectedTab = 0
    @State private var showingEditor = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(attacks: attacks, onRecord: { showingEditor = true })
                .tabItem { Label("Diario", systemImage: "plus.circle.fill") }
                .tag(0)
            HistoryView(attacks: attacks)
                .tabItem { Label("Storico", systemImage: "list.bullet") }
                .tag(1)
            CalendarView(attacks: attacks)
                .tabItem { Label("Calendario", systemImage: "calendar") }
                .tag(2)
            StatisticsView(attacks: attacks)
                .tabItem { Label("Statistiche", systemImage: "chart.bar") }
                .tag(3)
            SettingsView(attacks: attacks)
                .tabItem { Label("Impostazioni", systemImage: "gearshape") }
                .tag(4)
        }
        .tint(.purple)
        .sheet(isPresented: $showingEditor) {
            AttackEditorView()
        }
    }
}
