import SwiftUI

struct BatteryDetailViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: BatteryStorageBatteryCare
    let battery: BatteryModelBatteryCare
    
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
                        Text(battery.batteryBrand)
                            .font(.custom("Sarpanch-Bold", size: 32))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Text("Capacity")
                                .font(.custom("Sarpanch-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(battery.capacity)
                                .font(.custom("Sarpanch-Bold", size: 24))
                                .foregroundColor(.white)
                        }
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Service Life")
                                    .font(.custom("Sarpanch-Bold", size: 18))
                                    .foregroundColor(.white)
                                Text("(from manufacturer)")
                                    .font(.custom("Sarpanch-Bold", size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Text(battery.serviceLife)
                                .font(.custom("Sarpanch-Bold", size: 24))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Replacement")
                                .font(.custom("Sarpanch-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Image("calendarImageBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                
                                Text(formattedDate(battery.lastReplacement))
                                    .font(.custom("Sarpanch-Bold", size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        if !battery.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.custom("Sarpanch-Bold", size: 18))
                                    .foregroundColor(.white)
                                
                                Text(battery.notes)
                                    .font(.custom("Sarpanch-Bold", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        Image("cardBatteryCare")
                            .resizable()
                            .scaledToFill()
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
                        storage.deleteBattery(battery)
                        dismiss()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            AddBatteryViewBatteryCare(storage: storage, batteryToEdit: battery)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

struct DeleteConfirmationViewBatteryCare: View {
    @Binding var isPresented: Bool
    var onDelete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 20) {
                Text("Delete")
                    .font(.custom("Sarpanch-Bold", size: 28))
                    .foregroundColor(.white)
                
                Text("Are you sure you want to\ndelete this entry?\nThis action cannot be\nundone")
                    .font(.custom("Sarpanch-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button {
                        isPresented = false
                    } label: {
                        Image("btn_cancelBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                    
                    Button {
                        onDelete()
                    } label: {
                        Image("btn_delete_redBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                    }
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    BatteryDetailViewBatteryCare(
        storage: BatteryStorageBatteryCare(),
        battery: BatteryModelBatteryCare(
            lastReplacement: Date(),
            batteryBrand: "Varta Blue Dynamic",
            capacity: "60 Ah",
            serviceLife: "5 years",
            notes: "Installed at service"
        )
    )
}
