import SwiftUI

struct NoteDetailView: View {
    let note: Note?
    let noteManager: NoteManager
    let onNoteUpdated: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    
    var isNewNote: Bool {
        note == nil
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Note Title", text: $title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Divider()
                    
                    TextEditor(text: $content)
                        .font(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }
            .navigationTitle(isNewNote ? "New Note" : "Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
                
                if !isNewNote {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                if let note = note {
                    title = note.title ?? ""
                    content = note.content ?? ""
                }
            }
            .alert("Delete Note", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteNote()
                }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
        }
    }
    
    private func saveNote() {
        if isNewNote {
            if noteManager.createNote(title: title, content: content) {
                onNoteUpdated()
                dismiss()
            }
        } else if let note = note {
            if noteManager.updateNote(note, title: title, content: content) {
                onNoteUpdated()
                dismiss()
            }
        }
    }
    
    private func deleteNote() {
        if let note = note {
            if noteManager.deleteNote(note) {
                onNoteUpdated()
                dismiss()
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let user = User(context: context)
    user.id = UUID()
    user.username = "testuser"
    user.password = "password"
    user.createdAt = Date()
    
    let noteManager = NoteManager(viewContext: context, currentUser: user)
    
    return NoteDetailView(note: nil, noteManager: noteManager, onNoteUpdated: {})
}
