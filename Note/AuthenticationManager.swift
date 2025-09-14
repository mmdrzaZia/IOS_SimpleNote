import Foundation
import CoreData
import SwiftUI

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        // Check if there's a logged-in user
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(request)
            if let user = users.first {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("Error checking authentication status: \(error)")
        }
    }
    
    func register(username: String, password: String) -> Bool {
        // Check if username already exists
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let existingUsers = try viewContext.fetch(request)
            if !existingUsers.isEmpty {
                return false // Username already exists
            }
        } catch {
            print("Error checking existing users: \(error)")
            return false
        }
        
        // Create new user
        let newUser = User(context: viewContext)
        newUser.id = UUID()
        newUser.username = username
        newUser.password = password // In a real app, you'd hash this
        newUser.createdAt = Date()
        
        do {
            try viewContext.save()
            print("User registered successfully: \(username)")
            self.currentUser = newUser
            self.isAuthenticated = true
            return true
        } catch {
            print("Error saving user: \(error)")
            return false
        }
    }
    
    func login(username: String, password: String) -> Bool {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        do {
            let users = try viewContext.fetch(request)
            print("Login attempt for username: \(username)")
            print("Found \(users.count) users with matching credentials")
            
            if let user = users.first {
                print("Login successful for user: \(user.username ?? "unknown")")
                self.currentUser = user
                self.isAuthenticated = true
                return true
            } else {
                print("No user found with username: \(username)")
            }
        } catch {
            print("Error during login: \(error)")
        }
        
        return false
    }
    
    func logout() {
        print("Logout called")
        self.currentUser = nil
        self.isAuthenticated = false
        print("User logged out successfully")
    }
}
