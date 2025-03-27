import SwiftUI
import PhotosUI

struct EditPlayerView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @Binding var isTabbarVisible: Bool
    
    let player: PlayerModel
    
    @State private var playerName: String
    @State private var playerDescription: String
    @State private var gamesPlayed: Int
    @State private var gamesWon: Int
    
    @State private var selectedPhoto: UIImage?
    @State private var isImagePickerPresented = false
    
    init(player: PlayerModel, isTabbarVisible: Binding<Bool>) {
        self.player = player
        self._isTabbarVisible = isTabbarVisible
        
        _playerName = State(initialValue: player.name)
        _playerDescription = State(initialValue: player.description)
        _gamesPlayed = State(initialValue: player.gamesPlayed)
        _gamesWon = State(initialValue: player.gamesWon)
        
        if let filename = player.photoFilename {
            let image = GameManager().loadPlayerPhoto(filename: filename)
            _selectedPhoto = State(initialValue: image)
        }
    }
    
    var body: some View {
        ZStack {
            // Добавляем фон с жестом нажатия для скрытия клавиатуры
            Color(hex: "#17182D")
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            ScrollView(showsIndicators: false) {
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
                        Text("Edit Player")
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
                        
                        Text("Change Photo")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                    .padding(.bottom)
                    
                    // Форма редактирования игрока
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
                                .scrollContentBackground(.hidden)
                                .padding()
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
                                StatisticEditRow(
                                    icon: "gamecontroller.fill",
                                    title: "Games Played",
                                    value: $gamesPlayed
                                )
                                
                                // Победы
                                StatisticEditRow(
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
                        
                        // Кнопка сохранения
                        Button(action: savePlayer) {
                            Text("Save")
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
        .onDisappear {
            withAnimation {
                isTabbarVisible = true
            }
        }
    }
    
    // Рассчитываем процент побед
    var winRate: Int {
        if gamesPlayed == 0 {
            return 0
        }
        return Int((Double(gamesWon) / Double(gamesPlayed)) * 100)
    }
    
    // Сохранение изменений
    func savePlayer() {
        // Убедимся, что имя игрока заполнено
        guard !playerName.isEmpty else { return }
        
        // Убедимся что количество побед не превышает количество игр
        let finalGamesWon = min(gamesWon, gamesPlayed)
        
        // Обновляем игрока
        gameManager.updatePlayer(
            id: player.id,
            name: playerName,
            description: playerDescription,
            photo: selectedPhoto,
            gamesPlayed: gamesPlayed,
            gamesWon: finalGamesWon
        )
        
        // Включаем таббар перед закрытием экрана
        withAnimation {
            isTabbarVisible = true
        }
        
        // Закрываем экран
        dismiss()
    }
    
    // Функция для скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct StatisticEditRow: View {
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

#Preview {
    let demoPlayer = PlayerModel(id: UUID(), name: "Anton", description: "Game Master", photoFilename: nil, gamesPlayed: 24, gamesWon: 12)
    
    return EditPlayerView(player: demoPlayer, isTabbarVisible: .constant(true))
        .environmentObject(GameManager())
} 
