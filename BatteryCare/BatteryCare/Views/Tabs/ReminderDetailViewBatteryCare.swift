import SwiftUI

struct ReminderDetailViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: ReminderStorageBatteryCare
    let reminder: ReminderModelBatteryCare
    
    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    
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
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                      Image("progressBatteryCare")
                            .resizable()
                            .scaledToFit()
                        Text(reminder.reminderType)
                            .font(.custom("Sarpanch-Bold", size: 32))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            Image("calendarImageBatteryCare")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text(formattedDate(reminder.reminderDate))
                                .font(.custom("Sarpanch-Bold", size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "333333").opacity(0.8))
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Image("btn_editBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 93)
                    }
                    
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Image("btn_deleteBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 93)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            
            if showDeleteAlert {
                DeleteConfirmationViewBatteryCare(
                    isPresented: $showDeleteAlert,
                    onDelete: {
                        storage.deleteReminder(reminder)
                        dismiss()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            AddReminderViewBatteryCare(storage: storage, reminderToEdit: reminder)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    ReminderDetailViewBatteryCare(
        storage: ReminderStorageBatteryCare(),
        reminder: ReminderModelBatteryCare(
            reminderDate: Date(),
            reminderType: "Voltage Check"
        )
    )
    .preferredColorScheme(.dark)
}
