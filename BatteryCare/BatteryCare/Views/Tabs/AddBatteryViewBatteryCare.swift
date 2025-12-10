import SwiftUI

struct AddBatteryViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: BatteryStorageBatteryCare
    var batteryToEdit: BatteryModelBatteryCare?
    @State private var lastReplacement: Date = Date()
    @State private var batteryBrand: String = ""
    @State private var capacity: String = ""
    @State private var serviceLife: String = ""
    @State private var notes: String = ""
    @State private var showDatePicker: Bool = false
    
    private var isEditing: Bool {
        batteryToEdit != nil
    }
    
    private var canSave: Bool {
        !batteryBrand.isEmpty && !capacity.isEmpty && !serviceLife.isEmpty
    }
    
    init(storage: BatteryStorageBatteryCare, batteryToEdit: BatteryModelBatteryCare? = nil) {
        self.storage = storage
        self.batteryToEdit = batteryToEdit
        
        if let battery = batteryToEdit {
            _lastReplacement = State(initialValue: battery.lastReplacement)
            _batteryBrand = State(initialValue: battery.batteryBrand)
            _capacity = State(initialValue: battery.capacity)
            _serviceLife = State(initialValue: battery.serviceLife)
            _notes = State(initialValue: battery.notes)
        }
    }
    
    var body: some View {
        ZStack {
            Image("background_mainBatteryCare")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("btn_backBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 65)
                    }
                    
                    Spacer()
                    
                    Button {
                        saveBattery()
                    } label: {
                        Image("btn_doneBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 65)
                            .opacity(canSave ? 1.0 : 0.4)
                    }
                    .disabled(!canSave)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Replacement")
                                .font(.custom("Sarpanch-Bold", size: 19))
                                .foregroundColor(.white)
                            
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Text(formattedDate(lastReplacement))
                                        .font(.custom("Sarpanch-Bold", size: 22))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image("calendarImageBatteryCare")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 69)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(hex:"333333"))
                                )
                            }
                        }
                        
                        if showDatePicker {
                            DatePicker("", selection: $lastReplacement, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        
                        InputFieldBatteryCare(
                            title: "Battery Brand",
                            placeholder: "Write here",
                            text: $batteryBrand
                        )
                        
                        InputFieldBatteryCare(
                            title: "Capacity",
                            placeholder: "Write here",
                            text: $capacity
                        )
                        
                        InputFieldBatteryCare(
                            title: "Service Life (from manufacturer)",
                            placeholder: "Write here",
                            text: $serviceLife
                        )
                        
                        InputFieldBatteryCare(
                            title: "Notes",
                            placeholder: "Write here",
                            text: $notes
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
                
                Spacer()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    private func saveBattery() {
        var battery = batteryToEdit ?? BatteryModelBatteryCare.empty
        battery.lastReplacement = lastReplacement
        battery.batteryBrand = batteryBrand
        battery.capacity = capacity
        battery.serviceLife = serviceLife
        battery.notes = notes
        
        storage.saveBattery(battery)
        dismiss()
    }
}

struct InputFieldBatteryCare: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Sarpanch-Bold", size: 19))
                .foregroundColor(.white)
            
            HStack {
                TextField(placeholder, text: $text)
                    .font(.custom("Sarpanch-Bold", size: 22))
                    .foregroundColor(.white)
                    .accentColor(.white)
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 69)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex:"333333"))
            )
        }
    }
}

#Preview {
    AddBatteryViewBatteryCare(storage: BatteryStorageBatteryCare())
        .preferredColorScheme(.dark)
}
