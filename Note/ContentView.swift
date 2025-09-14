import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var authManager: AuthenticationManager

    init() {
        let context = PersistenceController.shared.container.viewContext
        _authManager = StateObject(wrappedValue: AuthenticationManager(viewContext: context))
    }

    var body: some View {
        if authManager.isAuthenticated, let currentUser = authManager.currentUser {
            NotesListView(viewContext: viewContext, currentUser: currentUser)
                .environmentObject(authManager)
        } else {
            LoginView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
