import SwiftUI

struct Tab1ContentViewBatteryCare: View {
    @StateObject private var storage = BatteryStorageBatteryCare()
    @State private var showAddBattery: Bool = false
    @State private var selectedBattery: BatteryModelBatteryCare?
    
    var body: some View {
        ZStack {
            VStack {
                Image("tab1_headerBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 108)
                
                if storage.batteries.isEmpty {
                    ZStack {
                        Image("empty_image_tab1BatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 308)
                        VStack {
                            Spacer()
                            Button {
                                showAddBattery = true
                            } label: {
                                Image("btn_plusBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 90)
                            }
                        }
                        .frame(height: 274)
                    }
                    .padding(.top, 104)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(storage.batteries) { battery in
                                BatteryCardViewBatteryCare(battery: battery)
                                    .onTapGesture {
                                        selectedBattery = battery
                                    }
                            }
                            
                            Button {
                                showAddBattery = true
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
        .fullScreenCover(isPresented: $showAddBattery) {
            AddBatteryViewBatteryCare(storage: storage)
        }
        .fullScreenCover(item: $selectedBattery) { battery in
            BatteryDetailViewBatteryCare(storage: storage, battery: battery)
        }
    }
}

struct BatteryCardViewBatteryCare: View {
    let battery: BatteryModelBatteryCare
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(battery.batteryBrand)
                .font(.custom("Sarpanch-Bold", size: 24))
                .foregroundColor(.white)
                .lineLimit(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Last Replacement")
                    .font(.custom("Sarpanch-Bold", size: 14))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Image("calendarImageBatteryCare")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text(formattedDate(battery.lastReplacement))
                        .font(.custom("Sarpanch-Bold", size: 18))
                        .foregroundColor(.white)
                }
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Service Life")
                        .font(.custom("Sarpanch-Bold", size: 14))
                        .foregroundColor(.white)
                    Text(battery.serviceLife)
                        .font(.custom("Sarpanch-Bold", size: 24))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Capacity")
                        .font(.custom("Sarpanch-Bold", size: 14))
                        .foregroundColor(.white)
                    Text(battery.capacity)
                        .font(.custom("Sarpanch-Bold", size: 24))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
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

#Preview("Tab1") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        Tab1ContentViewBatteryCare()
    }
}

#Preview("Battery Card") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        
        BatteryCardViewBatteryCare(
            battery: BatteryModelBatteryCare(
                lastReplacement: Date(),
                batteryBrand: "Varta Blue Dynamic",
                capacity: "60 Ah",
                serviceLife: "5 years",
                notes: ""
            )
        )
        .padding(.horizontal, 16)
    }
}
