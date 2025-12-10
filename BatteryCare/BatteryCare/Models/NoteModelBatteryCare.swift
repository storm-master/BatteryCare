import Foundation
import SwiftUI
import Combine

enum EventTypeBatteryCare: String, Codable, CaseIterable {
    case charging = "Charging"
    case draining = "Draining"
    case checking = "Checking in the service"
    
    var iconName: String {
        switch self {
        case .charging: return "chargingBatteryCare"
        case .draining: return "oraingngBatteryCare"
        case .checking: return "checkingBatteryCare"
        }
    }
}

struct NoteModelBatteryCare: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var eventType: EventTypeBatteryCare
    var note: String
    var imageData: Data?
    
    static var empty: NoteModelBatteryCare {
        NoteModelBatteryCare(
            date: Date(),
            eventType: .charging,
            note: "",
            imageData: nil
        )
    }
}

class NoteStorageBatteryCare: ObservableObject {
    @Published var notes: [NoteModelBatteryCare] = []
    
    private let storageKey = "batterycare_notes"
    
    init() {
        loadNotes()
    }
    
    func saveNote(_ note: NoteModelBatteryCare) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
        saveNotes()
    }
    
    func deleteNote(_ note: NoteModelBatteryCare) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([NoteModelBatteryCare].self, from: data) {
            notes = decoded
        }
    }
}

