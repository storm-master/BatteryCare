import SwiftUI

struct Tab3ContentViewBatteryCare: View {
    @StateObject private var storage = NoteStorageBatteryCare()
    @State private var showAddNote: Bool = false
    @State private var selectedNote: NoteModelBatteryCare?
    
    var body: some View {
        ZStack {
            VStack {
                Image("tab3_headerBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 108)
                
                if storage.notes.isEmpty {
                    ZStack {
                        Image("empty_image_tab2BatteryCare")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                        VStack {
                            Spacer()
                            Button {
                                showAddNote = true
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
                            ForEach(storage.notes) { note in
                                NoteCardViewBatteryCare(note: note)
                                    .onTapGesture {
                                        selectedNote = note
                                    }
                            }
                            
                            Button {
                                showAddNote = true
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
        .fullScreenCover(isPresented: $showAddNote) {
            AddNoteViewBatteryCare(storage: storage)
        }
        .fullScreenCover(item: $selectedNote) { note in
            NoteDetailViewBatteryCare(storage: storage, note: note)
        }
    }
}

struct NoteCardViewBatteryCare: View {
    let note: NoteModelBatteryCare
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image("calendarImageBatteryCare")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 35)
                Text(formattedDate(note.date))
                    .font(.custom("Sarpanch-Bold", size: 25))
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 10) {
                Image(note.eventType.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 92)
                
                Text(note.eventType.rawValue)
                    .font(.custom("Sarpanch-Bold", size: 25))
                    .foregroundColor(.white)
            }
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

#Preview("Tab3") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        Tab3ContentViewBatteryCare()
    }
}

#Preview("Note Card") {
    ZStack {
        Image("background_mainBatteryCare")
            .resizable()
            .ignoresSafeArea()
        
        NoteCardViewBatteryCare(
            note: NoteModelBatteryCare(
                date: Date(),
                eventType: .charging,
                note: "Test note",
                imageData: nil
            )
        )
        .padding(.horizontal, 16)
    }
}
