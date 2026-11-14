import SwiftUI
import SwiftData
import LocalAuthentication

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Attack.timestamp, order: .reverse) private var attacks: [Attack]
    @AppStorage("biometricLockEnabled") private var biometricLockEnabled = false
    @State private var selectedTab = 0
    @State private var showingEditor = false
    @State private var selectedAttack: Attack?
    @State private var isUnlocked = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(attacks: attacks, onRecord: recordAttack)
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
            if biometricLockEnabled && !isUnlocked {
                LockScreenView(onUnlock: authenticate)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let selectedAttack {
                AttackEditorView(attack: selectedAttack)
            }
        }
        .onAppear {
            if !biometricLockEnabled { isUnlocked = true }
        }
        .onChange(of: biometricLockEnabled) { _, enabled in
            if !enabled { isUnlocked = true }
            else { authenticate() }
        }
    }

    private func recordAttack() {
        let attack = Attack()
        context.insert(attack)
        do {
            try context.save()
            selectedAttack = attack
            showingEditor = true
        } catch {
            selectedAttack = nil
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Sblocca il tuo diario MigraNote") { success, _ in
            DispatchQueue.main.async { isUnlocked = success }
        }
    }
}

struct LockScreenView: View {
    let onUnlock: () -> Void
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "lock.fill").font(.system(size: 44)).foregroundStyle(.purple)
            Text("MigraNote è protetto").font(.title2.bold())
            Text("Sblocca per accedere al tuo diario.")
                .foregroundStyle(.secondary)
            Button(action: onUnlock) {
                Label("Sblocca con Face ID", systemImage: "faceid")
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}
