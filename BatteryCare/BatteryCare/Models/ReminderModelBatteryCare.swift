import Foundation
import Combine

struct ReminderModelBatteryCare: Identifiable, Codable {
    var id = UUID()
    var reminderDate: Date
    var reminderType: String
    
    static var empty: ReminderModelBatteryCare {
        ReminderModelBatteryCare(
            reminderDate: Date(),
            reminderType: ""
        )
    }
}

class ReminderStorageBatteryCare: ObservableObject {
    @Published var reminders: [ReminderModelBatteryCare] = []
    
    private let storageKey = "batterycare_reminders"
    
    init() {
        loadReminders()
    }
    
    func saveReminder(_ reminder: ReminderModelBatteryCare) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.append(reminder)
        }
        saveReminders()
    }
    
    func deleteReminder(_ reminder: ReminderModelBatteryCare) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([ReminderModelBatteryCare].self, from: data) {
            reminders = decoded
        }
    }
}

