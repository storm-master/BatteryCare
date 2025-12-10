import SwiftUI

struct AddReminderViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: ReminderStorageBatteryCare
    var reminderToEdit: ReminderModelBatteryCare?
    
    @State private var reminderDate: Date = Date()
    @State private var reminderType: String = ""
    @State private var showDatePicker: Bool = false
    
    private var isEditing: Bool {
        reminderToEdit != nil
    }
    
    private var canSave: Bool {
        !reminderType.isEmpty
    }
    
    init(storage: ReminderStorageBatteryCare, reminderToEdit: ReminderModelBatteryCare? = nil) {
        self.storage = storage
        self.reminderToEdit = reminderToEdit
        
        if let reminder = reminderToEdit {
            _reminderDate = State(initialValue: reminder.reminderDate)
            _reminderType = State(initialValue: reminder.reminderType)
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
                        saveReminder()
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
                            Text("Reminder Date")
                                .font(.custom("Sarpanch-Bold", size: 19))
                                .foregroundColor(.white)
                            
                            Button {
                                showDatePicker.toggle()
                            } label: {
                                HStack {
                                    Text(formattedDate(reminderDate))
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
                                        .fill(Color(hex: "333333"))
                                )
                            }
                        }
                        
                        if showDatePicker {
                            DatePicker("", selection: $reminderDate, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        
                        InputFieldBatteryCare(
                            title: "Reminder Type",
                            placeholder: "Write here",
                            text: $reminderType
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
    
    private func saveReminder() {
        var reminder = reminderToEdit ?? ReminderModelBatteryCare.empty
        reminder.reminderDate = reminderDate
        reminder.reminderType = reminderType
        
        storage.saveReminder(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderViewBatteryCare(storage: ReminderStorageBatteryCare())
        .preferredColorScheme(.dark)
}
