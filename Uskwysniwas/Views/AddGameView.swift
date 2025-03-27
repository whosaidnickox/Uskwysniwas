import SwiftUI
import PhotosUI

struct AddGameView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gameManager: GameManager
    @Binding var isTabbarVisible: Bool
    
    @State private var gameTitle = ""
    @State private var selectedGenre = ""
    @State private var playersCount = ""
    @State private var playTime = ""
    @State private var selectedDifficulty: GameModel.Difficulty = .easy
    @State private var rating = 0
    @State private var gameDescription = ""
    @State private var comments = ""
    
    @State private var isGenreDropdownOpen = false
    @State private var isPlayersDropdownOpen = false
    @State private var isPlaytimeDropdownOpen = false
    
    @State private var selectedPhotos: [UIImage] = []
    @State private var isImagePickerPresented = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let difficultyOptions: [GameModel.Difficulty] = [.easy, .medium, .hard]
    
    let genreOptions = [
        "Strategy",
        "Party Games",
        "Cooperative",
        "Deck-building",
        "Role-playing (RPG)",
        "Card Game",
        "Dice Game",
        "Puzzle"
    ]
    let playerOptions = [
        "1",
        "1-2",
        "2-4",
        "4-6",
        "6+",
        "Teams"
    ]
    let playtimeOptions = [
        "< 15 min",
        "15-30 min",
        "30-60 min",
        "1-2 hours",
        "2+ hours"
    ]
    
    var body: some View {
        ZStack {
            // Добавляем фон с жестом нажатия для скрытия клавиатуры
            Color(hex: "#17182D")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .center) {
                        Button {
                            dismiss()
                            withAnimation {
                                isTabbarVisible = true
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                        }
                        Text("Add New Game")
                            .font(.custom("DaysOne-Regular", size: 18))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .opacity(0)
                    }
                    
                    // Game title
                    TextField("", text: $gameTitle)
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "#2A2E46"))
                        .cornerRadius(12)
                        .overlay(
                            ZStack {
                                if gameTitle.isEmpty {
                                    Text("Game Title")
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(Color(hex: "#808080"))
                                        .padding(.leading, 16)
                                        .allowsHitTesting(false)
                                }
                            }, alignment: .leading
                        )

                    // Genre and Players
                    ZStack(alignment: .top) {
                        VStack(spacing: 16) {
                            // Genre Dropdown
                            DropdownMenu(
                                placeholder: "Select Genre",
                                selectedOption: $selectedGenre,
                                isOpen: $isGenreDropdownOpen,
                                options: genreOptions,
                                onOpen: { closeOtherDropdowns(.genre) }
                            )
                            .zIndex(isGenreDropdownOpen ? 10 : 1)
                            
                            HStack(spacing: 12) {
                                // Players Dropdown
                                DropdownMenu(
                                    placeholder: "Players",
                                    selectedOption: $playersCount,
                                    isOpen: $isPlayersDropdownOpen,
                                    options: playerOptions,
                                    onOpen: { closeOtherDropdowns(.players) }
                                )
                                .zIndex(isPlayersDropdownOpen ? 10 : 1)
                                
                                // Playtime Dropdown
                                DropdownMenu(
                                    placeholder: "Playtime",
                                    selectedOption: $playTime,
                                    isOpen: $isPlaytimeDropdownOpen,
                                    options: playtimeOptions,
                                    onOpen: { closeOtherDropdowns(.playtime) }
                                )
                                .zIndex(isPlaytimeDropdownOpen ? 10 : 1)
                            }
                            .zIndex(isPlayersDropdownOpen || isPlaytimeDropdownOpen ? 10 : 1)
                        }
                    }
                    .zIndex(10)
                    
                    // Difficulty level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty Level")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                        
                        HStack(spacing: 10) {
                            ForEach(difficultyOptions, id: \.self) { difficulty in
                                Button {
                                    selectedDifficulty = difficulty
                                    closeAllDropdowns()
                                } label: {
                                    Text(difficulty.rawValue)
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(selectedDifficulty == difficulty ? Color(hex: "#EB4150") : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedDifficulty == difficulty ? 
                                            Color(hex: "#EB4150").opacity(0.3) :
                                            Color(hex: "#2A2E46")
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        closeAllDropdowns()
                    }
                    
                    // Rating
                    VStack(alignment: .center, spacing: 10) {
                        Text("\(rating)")
                            .font(.custom("DaysOne-Regular", size: 36))
                            .foregroundColor(.white)
                            .padding(.trailing, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(spacing: 4) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    rating = star
                                } label: {
                                    Image(star <= rating ? "starFilled" : "starUnfilled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)

                        
                        Text("Your Rating")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 10) {
                        createTextEditor(placeholder: "Game Description", text: $gameDescription)
                    }
                    
                    // Comments
                    VStack(alignment: .leading, spacing: 10) {
                        createTextEditor(placeholder: "Your Comments (Optional)", text: $comments)
                    }
                    
                    // Add photos
                    VStack(alignment: .leading, spacing: 14) {
                        Button {
                            isImagePickerPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                                
                                Text("Add Game Photos")
                                    .font(.custom("DaysOne-Regular", size: 16))
                                    .foregroundColor(Color(hex: "#9CA3AF"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [2, 2]))
                                    .foregroundColor(Color(hex: "#2A2E46"))
                            )
                        }
                        
                        if !selectedPhotos.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(0..<selectedPhotos.count, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: selectedPhotos[index])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                            
                                            Button {
                                                selectedPhotos.remove(at: index)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.7))
                                                    .clipShape(Circle())
                                                    .padding(4)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // Save button
                    Button {
                        if validateInputs() {
                            saveGame()
                            dismiss()
                            withAnimation {
                                isTabbarVisible = true
                            }
                        } else {
                            showAlert = true
                        }
                    } label: {
                        Text("Save Game")
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#EB4150"))
                            .cornerRadius(12)
                    }
                    .padding(.vertical, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .background(Color(hex: "#17182D"))
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(images: $selectedPhotos, isPresented: $isImagePickerPresented)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            withAnimation {
                isTabbarVisible = false
            }
        }
    }
        
    private func createTextEditor(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: text)
                .font(.custom("DaysOne-Regular", size: 16))
                .foregroundColor(.white)
                .frame(minHeight: 100)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color(hex: "#2A2E46"))
                .cornerRadius(12)
                .scrollContentBackground(.hidden)
                .onTapGesture {
                    closeAllDropdowns()
                }
            
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(Color(hex: "#808080"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .allowsHitTesting(false)
            }
        }
    }
    
    enum DropdownType {
        case genre, players, playtime
    }
    
    private func closeAllDropdowns() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isGenreDropdownOpen = false
            isPlayersDropdownOpen = false
            isPlaytimeDropdownOpen = false
        }
    }
    
    private func closeOtherDropdowns(_ keepOpen: DropdownType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if keepOpen != .genre { isGenreDropdownOpen = false }
            if keepOpen != .players { isPlayersDropdownOpen = false }
            if keepOpen != .playtime { isPlaytimeDropdownOpen = false }
        }
    }
    
    private func validateInputs() -> Bool {
        if gameTitle.isEmpty {
            alertMessage = "Please enter a game title"
            return false
        }
        
        if selectedGenre.isEmpty {
            alertMessage = "Please select a genre"
            return false
        }
        
        if playersCount.isEmpty {
            alertMessage = "Please select number of players"
            return false
        }
        
        if playTime.isEmpty {
            alertMessage = "Please select playtime"
            return false
        }
        
        if gameDescription.isEmpty {
            alertMessage = "Please add a game description"
            return false
        }
        
        return true
    }
    
    private func saveGame() {
        gameManager.addGame(
            title: gameTitle,
            genre: selectedGenre,
            players: playersCount,
            playtime: playTime,
            difficulty: selectedDifficulty,
            rating: rating,
            description: gameDescription,
            comments: comments,
            photos: selectedPhotos
        )
    }
    
    // Добавляю функцию для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct DropdownMenu: View {
    let placeholder: String
    @Binding var selectedOption: String
    @Binding var isOpen: Bool
    let options: [String]
    var onOpen: () -> Void
    
    var body: some View {
        Button {
            onOpen()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOpen.toggle()
            }
        } label: {
            HStack {
                Text(selectedOption.isEmpty ? placeholder : selectedOption)
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(selectedOption.isEmpty ? Color(hex: "#808080") : .white)
                    .lineLimit(1)
                    .padding()
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(Color(hex: "#808080"))
                    .rotationEffect(isOpen ? .degrees(180) : .degrees(0))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOpen)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#2A2E46"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: isOpen ? "#808080" : "#2A2E46"), lineWidth: 1)
            )
        }
        .overlay(alignment: .top) {
            if isOpen {
                VStack(spacing: 0) {
                    // Spacer for pushing down the options
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 55) // Height to push down to match header
                    
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedOption = option
                                    isOpen = false
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                    
                                    Spacer()
                                    
                                    if selectedOption == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Color(hex: "#EB4150"))
                                            .padding(.trailing, 16)
                                    }
                                }
                                .background(
                                    selectedOption == option ? 
                                        Color(hex: "#EB4150").opacity(0.15) : 
                                        Color.clear
                                )
                                .frame(maxWidth: .infinity)
                            }
                            
                            if option != options.last {
                                Divider()
                                    .background(Color(hex: "#3A3E56"))
                                    .padding(.horizontal, 10)
                            }
                        }
                    }
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 5
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Update logic here if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.images.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddGameView(isTabbarVisible: .constant(true))
    }
}
