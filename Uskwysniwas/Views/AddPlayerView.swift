import SwiftUI
import PhotosUI

struct AddPlayerView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isTabbarVisible: Bool
    
    @State private var playerName = ""
    @State private var playerDescription = ""
    @State private var gamesPlayed = 0
    @State private var gamesWon = 0
    
    @State private var selectedPhoto: UIImage?
    @State private var isImagePickerPresented = false
    @State private var photoItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            // Добавляем фон с жестом нажатия для скрытия клавиатуры
            Color(hex: "#17182D")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                
            ScrollView {
                VStack(spacing: 24) {
                    // Заголовок с кнопкой назад
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
                        Text("Add New Player")
                            .font(.custom("DaysOne-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .opacity(0)
                    }
                    .padding(.top)
                    
                    // Фото игрока
                    VStack(spacing: 12) {
                        Button {
                            isImagePickerPresented = true
                        } label: {
                            if let photo = selectedPhoto {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#EB4150"), lineWidth: 2)
                                    )
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(Color(hex: "#2A2E46"))
                            }
                        }
                        
                        Text("Upload Photo")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                    .padding(.bottom)
                    
                    // Форма добавления игрока
                    VStack(spacing: 24) {
                        // Имя игрока
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Player Name")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            
                            TextField("", text: $playerName)
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#2A2E46"))
                                .cornerRadius(12)
                                .overlay(
                                    ZStack {
                                        if playerName.isEmpty {
                                            Text("Enter player name")
                                                .font(.custom("DaysOne-Regular", size: 16))
                                                .foregroundColor(Color(hex: "#808080"))
                                                .padding(.leading, 16)
                                                .allowsHitTesting(false)
                                        }
                                    }, alignment: .leading
                                )
                        }
                        
                        // Описание
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            
                            TextEditor(text: $playerDescription)
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .scrollContentBackground(.hidden)
                                .frame(height: 100)
                                .background(Color(hex: "#2A2E46"))
                                .cornerRadius(12)
                                .overlay(
                                    ZStack {
                                        if playerDescription.isEmpty {
                                            Text("Description about player")
                                                .font(.custom("DaysOne-Regular", size: 16))
                                                .foregroundColor(Color(hex: "#808080"))
                                                .padding(.top, 24)
                                                .padding(.leading, 16)
                                                .allowsHitTesting(false)
                                        }
                                    }, alignment: .topLeading
                                )
                        }
                        
                        // Игровая статистика
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Game Statistics")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            
                            VStack(spacing: 16) {
                                // Игры
                                StatisticRow(
                                    icon: "gamecontroller.fill",
                                    title: "Games Played",
                                    value: $gamesPlayed
                                )
                                
                                // Победы
                                StatisticRow(
                                    icon: "trophy.fill",
                                    title: "Wins",
                                    value: $gamesWon
                                )
                                
                                // Процент побед (расчетный)
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#17182D"))
                                            .frame(width: 30, height: 30)
                                        
                                        Image(systemName: "percent")
                                            .foregroundColor(.white)
                                            .font(.system(size: 14))
                                    }
                                    
                                    Text("Win Rate")
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(winRate)%")
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(Color(hex: "#9CA3AF"))
                                        .frame(width: 80)
                                        .padding(8)
                                        .background(Color(hex: "#17182D"))
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                        }
                        
                        // Кнопка добавления
                        Button(action: addPlayer) {
                            Text("Add Player")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#EB4150"))
                                .cornerRadius(12)
                        }
                        .padding(.top)
                    }
                }
                .padding(.horizontal)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isImagePickerPresented) {
            SingleImagePicker(image: $selectedPhoto, isPresented: $isImagePickerPresented)
        }
        .onAppear {
            withAnimation {
                isTabbarVisible = false
            }
        }
    }
    
    // Добавляю функцию скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Рассчитываем процент побед
    var winRate: Int {
        if gamesPlayed == 0 {
            return 0
        }
        return Int((Double(gamesWon) / Double(gamesPlayed)) * 100)
    }
    
    // Добавление игрока
    func addPlayer() {
        // Убедимся, что имя игрока заполнено
        guard !playerName.isEmpty else { return }
        
        // Создаем нового игрока
        _ = gameManager.addPlayer(
            name: playerName,
            description: playerDescription,
            photo: selectedPhoto,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon
        )
        // Закрываем экран
        dismiss()
        withAnimation {
            isTabbarVisible = true
        }
    }
}

struct StatisticRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(hex: "#17182D"))
                    .frame(width: 30, height: 30)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
            
            Text(title)
                .font(.custom("DaysOne-Regular", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Button {
                    if value > 0 {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color(hex: "#EB4150"))
                        .clipShape(Circle())
                }
                
                Text("\(value)")
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(width: 40)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#17182D"))
                    .cornerRadius(8)
                
                Button {
                    value += 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color(hex: "#EB4150"))
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct SingleImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
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
        let parent: SingleImagePicker
        
        init(_ parent: SingleImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let result = results.first else { return }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.image = image
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddPlayerView(isTabbarVisible: .constant(true))
        .environmentObject(GameManager())
} 
