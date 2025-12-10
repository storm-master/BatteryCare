import SwiftUI
import PhotosUI

struct AddNoteViewBatteryCare: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: NoteStorageBatteryCare
    var noteToEdit: NoteModelBatteryCare?
    
    @State private var date: Date = Date()
    @State private var eventType: EventTypeBatteryCare = .charging
    @State private var note: String = ""
    @State private var selectedImage: UIImage?
    @State private var showDatePicker: Bool = false
    @State private var showImagePicker: Bool = false
    
    private var isEditing: Bool {
        noteToEdit != nil
    }
    
    private var canSave: Bool {
        true
    }
    
    init(storage: NoteStorageBatteryCare, noteToEdit: NoteModelBatteryCare? = nil) {
        self.storage = storage
        self.noteToEdit = noteToEdit
        
        if let existingNote = noteToEdit {
            _date = State(initialValue: existingNote.date)
            _eventType = State(initialValue: existingNote.eventType)
            _note = State(initialValue: existingNote.note)
            if let imageData = existingNote.imageData {
                _selectedImage = State(initialValue: UIImage(data: imageData))
            }
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
                        saveNote()
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
                        Button {
                            showImagePicker = true
                        } label: {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 129, height: 129)
                                    .clipped()
                                    .cornerRadius(16)
                            } else {
                                Image("btn_add_galleryBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Text(formattedDate(date))
                                    .font(.custom("Sarpanch-Bold", size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image("calendarImageBatteryCare")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "333333"))
                            )
                        }
                        
                        if showDatePicker {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Event Type")
                                .font(.custom("Sarpanch-Bold", size: 17))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                EventTypeButtonBatteryCare(
                                    type: .charging,
                                    isSelected: eventType == .charging
                                ) {
                                    eventType = .charging
                                }
                                
                                EventTypeButtonBatteryCare(
                                    type: .draining,
                                    isSelected: eventType == .draining
                                ) {
                                    eventType = .draining
                                }
                            }
                            
                            HStack(spacing: 12) {
                                EventTypeButtonBatteryCare(
                                    type: .checking,
                                    isSelected: eventType == .checking
                                ) {
                                    eventType = .checking
                                }
                                
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "333333"))
                        )
                        
                        InputFieldBatteryCare(
                            title: "Note",
                            placeholder: "Write here",
                            text: $note
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerBatteryCare(image: $selectedImage)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    private func saveNote() {
        var noteModel = noteToEdit ?? NoteModelBatteryCare.empty
        noteModel.date = date
        noteModel.eventType = eventType
        noteModel.note = note
        noteModel.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        storage.saveNote(noteModel)
        dismiss()
    }
}

struct EventTypeButtonBatteryCare: View {
    let type: EventTypeBatteryCare
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(type.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                
                Text(type == .checking ? "Checking in the\nservice" : type.rawValue)
                    .font(.custom("Sarpanch-Bold", size: 12))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: isSelected ? "555555" : "444444"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.white.opacity(0.6) : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

struct ImagePickerBatteryCare: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerBatteryCare
        
        init(_ parent: ImagePickerBatteryCare) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddNoteViewBatteryCare(storage: NoteStorageBatteryCare())
        .preferredColorScheme(.dark)
}
