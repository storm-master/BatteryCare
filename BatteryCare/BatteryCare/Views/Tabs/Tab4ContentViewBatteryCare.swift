import SwiftUI
import UserNotifications
import WebKit

struct Tab4ContentViewBatteryCare: View {
    @AppStorage("notifications_enabled") private var notificationsEnabled: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image("tab4_headerBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 108)
                
                VStack(spacing: 10) {
                    Button {
                        notificationsEnabled.toggle()
                        handleNotificationToggle(notificationsEnabled)
                    } label: {
                        HStack {
                            Text("Notification")
                                .font(.custom("Sarpanch-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(notificationsEnabled ? "toggle_onBatteryCare" : "toggle_offBatteryCare")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 34)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            Image("field_emptyBatteryCare")
                                .resizable()
                        )
                    }
                    
                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        HStack {
                            Text("Privacy Policy")
                                .font(.custom("Sarpanch-Bold", size: 18))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            Image("field_emptyBatteryCare")
                                .resizable()
                        )
                    }
                    
                    HStack {
                        Text("Clear All Data")
                            .font(.custom("Sarpanch-Bold", size: 18))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Image("btn_deleteBatteryCare")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 45)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Image("field_emptyBatteryCare")
                            .resizable()
                    )
                }
                .padding(16)
                .background(
                    Image("rectangle_settingsBatteryCare")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.top, 60)
                
                Spacer()
            }
            
            if showDeleteAlert {
                ClearDataConfirmationViewBatteryCare(
                    isPresented: $showDeleteAlert,
                    onDelete: {
                        clearAllData()
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyViewBatteryCare()
        }
    }
    
    private func handleNotificationToggle(_ enabled: Bool) {
        if enabled {
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    notificationsEnabled = false
                }
            }
        }
    }
    
    private func clearAllData() {
        UserDefaults.standard.removeObject(forKey: "batterycare_batteries")
        UserDefaults.standard.removeObject(forKey: "batterycare_reminders")
        UserDefaults.standard.removeObject(forKey: "batterycare_notes")
        
        UserDefaults.standard.synchronize()
    }
}

struct ClearDataConfirmationViewBatteryCare: View {
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
                
                Text("Are you sure you want to\ndelete the entire history?\nThis action cannot be\nundone")
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
                        isPresented = false
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

struct PrivacyPolicyViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    
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
                
                WebViewBatteryCare(url: URL(string: "https://www.termsfeed.com/live/6cba9ab5-86fe-4cd0-a14a-c0536aa8476c")!)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
            }
        }
    }
}

struct WebViewBatteryCare: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

#Preview {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        Tab4ContentViewBatteryCare()
    }
}
