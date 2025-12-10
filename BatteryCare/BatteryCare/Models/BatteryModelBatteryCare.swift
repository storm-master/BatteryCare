import Foundation
import Combine

struct BatteryModelBatteryCare: Identifiable, Codable {
    var id = UUID()
    var lastReplacement: Date
    var batteryBrand: String
    var capacity: String
    var serviceLife: String
    var notes: String
    
    static var empty: BatteryModelBatteryCare {
        BatteryModelBatteryCare(
            lastReplacement: Date(),
            batteryBrand: "",
            capacity: "",
            serviceLife: "",
            notes: ""
        )
    }
}

class BatteryStorageBatteryCare: ObservableObject {
    @Published var batteries: [BatteryModelBatteryCare] = []
    
    private let storageKey = "batterycare_batteries"
    
    init() {
        loadBatteries()
    }
    
    func saveBattery(_ battery: BatteryModelBatteryCare) {
        if let index = batteries.firstIndex(where: { $0.id == battery.id }) {
            batteries[index] = battery
        } else {
            batteries.append(battery)
        }
        saveBatteries()
    }
    
    func deleteBattery(_ battery: BatteryModelBatteryCare) {
        batteries.removeAll { $0.id == battery.id }
        saveBatteries()
    }
    
    private func saveBatteries() {
        if let encoded = try? JSONEncoder().encode(batteries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadBatteries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([BatteryModelBatteryCare].self, from: data) {
            batteries = decoded
        }
    }
}

