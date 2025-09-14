import SwiftUI
import CoreData

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var noteManager: NoteManager
    @State private var notes: [Note] = []
    @State private var showingAddNote = false
    @State private var selectedNote: Note?
    
    init(viewContext: NSManagedObjectContext, currentUser: User) {
        _noteManager = StateObject(wrappedValue: NoteManager(viewContext: viewContext, currentUser: currentUser))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if notes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Notes Yet")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("Tap the + button to create your first note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(notes, id: \.id) { note in
                            NavigationLink(destination: NoteDetailView(note: note, noteManager: noteManager, onNoteUpdated: loadNotes)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title ?? "Untitled")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let content = note.content, !content.isEmpty {
                                        Text(content)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    
                                    Text(note.updatedAt ?? Date(), formatter: dateFormatter)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("My Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") {
                        authManager.logout()
                    }
                }
            }
            .onAppear {
                loadNotes()
            }
            .sheet(isPresented: $showingAddNote) {
                NoteDetailView(note: nil, noteManager: noteManager, onNoteUpdated: loadNotes)
            }
        }
    }
    
    private func loadNotes() {
        notes = noteManager.fetchNotes()
    }
    
    private func deleteNotes(offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            _ = noteManager.deleteNote(note)
        }
        loadNotes()
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let user = User(context: context)
    user.id = UUID()
    user.username = "testuser"
    user.password = "password"
    user.createdAt = Date()
    
    let authManager = AuthenticationManager(viewContext: context)
    return NotesListView(viewContext: context, currentUser: user)
        .environmentObject(authManager)
}
