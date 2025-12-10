import SwiftUI

struct Tab2ContentViewBatteryCare: View {
    @StateObject private var storage = ReminderStorageBatteryCare()
    @State private var showAddReminder: Bool = false
    @State private var selectedReminder: ReminderModelBatteryCare?
    
    var body: some View {
        ZStack {
            VStack {
                Image("tab2_headerBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 108)
                
                if storage.reminders.isEmpty {
                    ZStack {
                        Image("empty_image_tab2BatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                        VStack {
                            Spacer()
                            Button {
                                showAddReminder = true
                            } label: {
                                Image("btn_plusBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 90)
                            }
                        }
                        .frame(height: 234)
                    }
                    .padding(.top, 104)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(storage.reminders) { reminder in
                                ReminderCardViewBatteryCare(reminder: reminder)
                                    .onTapGesture {
                                        selectedReminder = reminder
                                    }
                            }
                            
                            Button {
                                showAddReminder = true
                            } label: {
                                Image("btn_plusBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 70)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showAddReminder) {
            AddReminderViewBatteryCare(storage: storage)
        }
        .fullScreenCover(item: $selectedReminder) { reminder in
            ReminderDetailViewBatteryCare(storage: storage, reminder: reminder)
        }
    }
}

struct ReminderCardViewBatteryCare: View {
    let reminder: ReminderModelBatteryCare
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reminder.reminderType)
                .font(.custom("Sarpanch-Bold", size: 20))
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack(spacing: 6) {
                Image("calendarImageBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                Text(formattedDate(reminder.reminderDate))
                    .font(.custom("Sarpanch-Bold", size: 16))
                    .foregroundColor(.white)
            }
            Image("progressBatteryCare")
                  .resizable()
                  .scaledToFit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            Image("cardBatteryCare")
                .resizable()
                .scaledToFill()
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

#Preview("Tab2") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        Tab2ContentViewBatteryCare()
    }
}

#Preview("Reminder Card") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        
        ReminderCardViewBatteryCare(
            reminder: ReminderModelBatteryCare(
                reminderDate: Date(),
                reminderType: "Voltage Check"
            )
        )
        .padding(.horizontal, 16)
    }
}
