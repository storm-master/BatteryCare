import SwiftUI

struct NoteDetailViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: NoteStorageBatteryCare
    let note: NoteModelBatteryCare
    
    @State private var showEditSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showFullImage: Bool = false
    
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
                    
                    HStack(spacing: 8) {
                        Image("calendarImageBatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(formattedDate(note.date))
                            .font(.custom("Sarpanch-Bold", size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 8) {
                            Image(note.eventType.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                            
                            Text(note.eventType.rawValue)
                                .font(.custom("Sarpanch-Bold", size: 16))
                                .foregroundColor(.white)
                        }
                        .frame(width: 120)
                        .padding(.vertical, 16)
                        .background(
                            Image("cardBatteryCare")
                                .resizable()
                                .scaledToFill()
                        )
                        
                        if let imageData = note.imageData, let uiImage = UIImage(data: imageData) {
                            Button {
                                showFullImage = true
                            } label: {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 90)
                                    .clipped()
                                    .cornerRadius(12)
                            }
                        }
                        
                        if !note.note.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Note")
                                    .font(.custom("Sarpanch-Bold", size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(note.note)
                                    .font(.custom("Sarpanch-Bold", size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
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
                        storage.deleteNote(note)
                        dismiss()
                    }
                )
            }
            
            if showFullImage, let imageData = note.imageData, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Color.black.opacity(0.9)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showFullImage = false
                        }
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
        }
        .fullScreenCover(isPresented: $showEditSheet) {
            AddNoteViewBatteryCare(storage: storage, noteToEdit: note)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NoteDetailViewBatteryCare(
        storage: NoteStorageBatteryCare(),
        note: NoteModelBatteryCare(
            date: Date(),
            eventType: .charging,
            note: "Voltage drop after -15°C night",
            imageData: nil
        )
    )
}
