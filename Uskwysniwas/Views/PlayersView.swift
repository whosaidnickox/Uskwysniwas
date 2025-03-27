import SwiftUI

struct PlayersView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Binding var isTabbarVisible: Bool
    @State private var showAddPlayer = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Players")
                        .font(.custom("DaysOne-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    if !gameManager.players.isEmpty {
                        Text("\(gameManager.players.count) active players")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                            .padding(.horizontal, 20)
                    }
                    
                    if gameManager.players.isEmpty {
                        // Нет игроков
                        emptyPlayersView
                    } else {
                        // Список игроков
                        VStack(spacing: 12) {
                            ForEach(gameManager.players) { player in
                                PlayerCard(player: player, gameManager: gameManager, isTabbarVisible: $isTabbarVisible)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            
            HStack {
                Spacer()
                NavigationLink {
                    AddPlayerView(isTabbarVisible: $isTabbarVisible)
                        .environmentObject(gameManager)
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Add player")
                            .font(.custom("DaysOne-Regular", size: 16))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "#EB4150"))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                Spacer()
            }
            .padding(.bottom, 85)
            .opacity(!gameManager.players.isEmpty ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#17182D"))
        .navigationBarHidden(true)
    }
    
    // Вид для пустого списка игроков
    private var emptyPlayersView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            
            Image(systemName: "person.3")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#9CA3AF"))
            
            Text("You haven't added any players yet")
                .font(.custom("DaysOne-Regular", size: 18))
                .foregroundColor(Color(hex: "#9CA3AF"))
                .multilineTextAlignment(.center)
            
            NavigationLink {
                AddPlayerView(isTabbarVisible: $isTabbarVisible)
                    .environmentObject(gameManager)
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    Text("Add Your First Player")
                        .font(.custom("DaysOne-Regular", size: 16))
                }
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(Color(hex: "#EB4150"))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }
}

struct PlayerCard: View {
    let player: PlayerModel
    let gameManager: GameManager
    @Binding var isTabbarVisible: Bool
    
    var body: some View {
        NavigationLink {
            EditPlayerView(player: player, isTabbarVisible: $isTabbarVisible)
                .environmentObject(gameManager)
        } label: {
            VStack(spacing: 0) {
                // Верхняя секция с фото и информацией
                HStack(spacing: 16) {
                    // Фото игрока
                    if let photoFilename = player.photoFilename {
                        Image(uiImage: gameManager.loadPlayerPhoto(filename: photoFilename))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                    
                    // Имя и описание
                    VStack(alignment: .leading, spacing: 4) {
                        Text(player.name)
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                        
                        Text(player.description)
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                    
                    Spacer()
                    
                    // Иконка ">"
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                .padding(16)
                
                // Нижняя секция со статистикой
                HStack(spacing: 12) {
                    // Игры
                    StatBox(value: "\(player.gamesPlayed)", label: "Games")
                    
                    // Победы
                    StatBox(value: "\(player.gamesWon)", label: "Wins")
                    
                    // Процент побед
                    StatBox(value: "\(player.winRate)%", label: "Win Rate")
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(hex: "#2A2E46"))
            .cornerRadius(12)
        }
        .contextMenu {
            Button(role: .destructive) {
                if let index = gameManager.players.firstIndex(where: { $0.id == player.id }) {
                    gameManager.deletePlayer(at: index)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct StatBox: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("DaysOne-Regular", size:
                    18))
                .foregroundColor(Color(hex: "#EB4150"))
            
            Text(label)
                .font(.custom("DaysOne-Regular", size: 12))
                .foregroundColor(Color(hex: "#9CA3AF"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(hex: "#17182D"))
        .cornerRadius(8)
    }
}

#Preview {
    PlayersView(isTabbarVisible: .constant(true))
        .environmentObject(GameManager())
} 
