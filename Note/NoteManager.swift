import Foundation
import CoreData
import SwiftUI

class NoteManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    private let currentUser: User
    
    init(viewContext: NSManagedObjectContext, currentUser: User) {
        self.viewContext = viewContext
        self.currentUser = currentUser
    }
    
    func createNote(title: String, content: String) -> Bool {
        let newNote = Note(context: viewContext)
        newNote.id = UUID()
        newNote.title = title
        newNote.content = content
        newNote.createdAt = Date()
        newNote.updatedAt = Date()
        newNote.user = currentUser
        
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error creating note: \(error)")
            return false
        }
    }
    
    func updateNote(_ note: Note, title: String, content: String) -> Bool {
        note.title = title
        note.content = content
        note.updatedAt = Date()
        
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error updating note: \(error)")
            return false
        }
    }
    
    func deleteNote(_ note: Note) -> Bool {
        viewContext.delete(note)
        
        do {
            try viewContext.save()
            return true
        } catch {
            print("Error deleting note: \(error)")
            return false
        }
    }
    
    func fetchNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", currentUser)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.updatedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
}
