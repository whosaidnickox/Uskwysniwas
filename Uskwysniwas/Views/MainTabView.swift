import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab: TabBarItem = .games
    @State private var isTabBarVisible: Bool = true
    
    // Добавляем состояние для отслеживания открытия экрана Random
    @State private var isRandomViewPresented = false
    // Сохраняем предыдущий выбранный таб
    @State private var previousSelectedTab: TabBarItem = .games
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    GamesView(isTabbarVisible: $isTabBarVisible)
                        .environmentObject(gameManager)
                }
                .tag(TabBarItem.games)
                
                NavigationStack {
                    AlertsView(isShowTabbar: $isTabBarVisible)
                        .environmentObject(gameManager)
                }
                .tag(TabBarItem.alerts)
                
                // Пустой экран для Random, так как он будет показываться как модальное окно
                Color.clear.opacity(0)
                    .tag(TabBarItem.random)
                
                NavigationStack {
                    PlayersView(isTabbarVisible: $isTabBarVisible)
                        .environmentObject(gameManager)
                }
                .tag(TabBarItem.players)
                
                NavigationStack {
                    SettingsView(isTabbarVisible: $isTabBarVisible)
                        .environmentObject(gameManager)
                }
                .tag(TabBarItem.settings)
            }
            
            CustomTabBar(selectedTab: $selectedTab, onRandomTap: {
                // При тапе на Random сохраняем текущий выбранный таб
                previousSelectedTab = selectedTab
                // Показываем модальное окно
                isRandomViewPresented = true
            })
            .padding(.horizontal, 16)
            .ignoresSafeArea(.keyboard)
            .opacity(isTabBarVisible ? 1 : 0)
        }
        .animation(.bouncy, value: isTabBarVisible)
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $isRandomViewPresented, onDismiss: {
            // После закрытия модального окна возвращаем предыдущий таб
            selectedTab = previousSelectedTab
            // Показываем таббар снова
            isTabBarVisible = true
        }) {
            RandomView(isPresented: $isRandomViewPresented)
                .environmentObject(gameManager)
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarItem
    var onRandomTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color(hex: "#EB4150").opacity(0.23))
                .frame(height: 71)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            HStack(spacing: 0) {
                ForEach(TabBarItem.allCases, id: \.self) { tab in
                    if tab == .random {
                        // Кнопка Random с особой обработкой
                        TabBarButton(
                            tab: tab,
                            selectedTab: $selectedTab,
                            action: {
                                onRandomTap()
                            }
                        )
                    } else {
                        // Обычные кнопки таба
                        TabBarButton(
                            tab: tab,
                            selectedTab: $selectedTab
                        )
                    }
                }
            }
            .padding(.horizontal, 22)
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarButton: View {
    let tab: TabBarItem
    @Binding var selectedTab: TabBarItem
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            if let customAction = action {
                customAction()
            } else {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = tab
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(tab.icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(
                        selectedTab == tab
                        ? Color(hex: "#EB4150")
                        : .white.opacity(0.4)
                    )
                    .frame(width: 24, height: 20)
                    .padding(.top, 5)
                
                Text(tab.rawValue)
                    .font(.custom("DaysOne-Regular", size: 12))
                    .foregroundColor(
                        selectedTab == tab
                        ? Color(hex: "#EB4150")
                        : .white.opacity(0.4)
                    )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Создаем экран Random
struct RandomView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var gameManager: GameManager
    
    @State private var randomGame: GameModel? = nil
    @State private var isShowingResult = false
    
    var body: some View {
        ZStack {
            // Фон
            Color(hex: "#17182D").ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Верхняя часть с заголовком и кнопкой закрытия
                ZStack {
                    
                    HStack {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    HStack(spacing: 12) {
                        Image("Cube")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                        
                        Text("What to Play?")
                            .font(.custom("DaysOne-Regular", size: 20))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                if isShowingResult && randomGame != nil {
                    // Показываем результат
                    resultView
                } else {
                    // Показываем начальный экран
                    initialView
                }
                
                Spacer()
            }
        }
    }
    
    // Начальный экран с описанием и кнопкой Roll
    var initialView: some View {
        VStack(spacing: 40) {
            
            // Текст и описание
            VStack(spacing: 12) {
                Text("Can't Decide?")
                    .font(.custom("DaysOne-Regular", size: 24))
                    .foregroundColor(.white)
                
                Text("Let us help you pick the perfect game for your next session!")
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(Color(hex: "#9CA3AF"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Куб по центру
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "#2A2E46"))
                    .frame(width: 150, height: 150)
                
                Image(.cube)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 65)
            }
            Spacer()
            // Кнопка Roll
            Button {
                rollRandomGame()
            } label: {
                HStack(spacing: 10) {
                    Image("onboarding1_icon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 24)
                    
                    Text("Roll!")
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
                .padding(.horizontal, 30)
                .background(Color(hex: "#EB4150"))
                .cornerRadius(12)
                .frame(height: 55)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
        }
        .padding()
    }
    
    // Экран с результатом
    var resultView: some View {
        VStack(spacing: 25) {
            if gameManager.games.isEmpty {
                // Состояние, когда нет игр
                VStack(spacing: 20) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                    
                    Text("No Games Found")
                        .font(.custom("DaysOne-Regular", size: 20))
                        .foregroundColor(.white)
                    
                    Text("Add games to your collection first")
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Кнопка закрытия
                    Button {
                        isPresented = false
                    } label: {
                        Text("Back to Games")
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#EB4150"))
                            .cornerRadius(12)
                            .frame(height: 55)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .padding()
            } else if gameManager.games.count == 1 {
                // Состояние, когда есть только одна игра
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "dice")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                    
                    Text("Need More Games")
                        .font(.custom("DaysOne-Regular", size: 20))
                        .foregroundColor(.white)
                    
                    Text("Add at least one more game to use the random feature")
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer()
                    // Кнопка закрытия
                    Button {
                        isPresented = false
                    } label: {
                        Text("Back to Games")
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#EB4150"))
                            .cornerRadius(12)
                            .frame(height: 55)
                    }
                }
                .padding()
            } else {
                // Карточка игры
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 16) {
                        // Изображение игры
                        ZStack {
                            if let game = randomGame, !game.photoFilenames.isEmpty {
                                Image(uiImage: gameManager.loadPhoto(filename: game.photoFilenames[0]))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color(hex: "#EB4150"))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                                    .overlay(
                                        Image(systemName: "gamecontroller")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                    )
                            }
                        }
                        
                        // Информация о игре
                        VStack(alignment: .leading, spacing: 6) {
                            Text(randomGame?.title ?? "Unknown Game")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                            
                            Text(randomGame?.genre ?? "")
                                .font(.custom("DaysOne-Regular", size: 12))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            
                            // Детали игры
                            HStack(spacing: 16) {
                                // Игроки
                                HStack(spacing: 4) {
                                    Image("person")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(randomGame?.players ?? "")
                                        .font(.custom("DaysOne-Regular", size: 12))
                                        .foregroundColor(.white)
                                }
                                
                                // Время
                                HStack(spacing: 4) {
                                    Image("clock")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(formatPlaytime(randomGame?.playtime ?? ""))
                                        .font(.custom("DaysOne-Regular", size: 12))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                
                                // Сложность
                                HStack(spacing: 4) {
                                    Image("star")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                    
                                    Text(formatDifficulty(randomGame?.difficulty.rawValue ?? ""))
                                        .font(.custom("DaysOne-Regular", size: 12))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(Color(hex: "#2A2E46"))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Кнопки действий
                VStack(spacing: 12) {
                    // Roll Again
                    Button {
                        rollRandomGame()
                    } label: {
                        HStack(spacing: 10) {
                            Image("onboarding1_icon")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                            
                            Text("Roll Again!")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#EB4150"))
                        .cornerRadius(12)
                        .frame(height: 55)
                    }
                    
                    // Let's Play This
                    Button {
                        isPresented = false
                    } label: {
                        Text("Let's Play This!")
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // Функция для получения случайной игры
    private func rollRandomGame() {
        // Проверяем, есть ли игры
        guard !gameManager.games.isEmpty else {
            randomGame = nil
            isShowingResult = true
            return
        }
        
        // Проверяем, есть ли минимум 2 игры
        guard gameManager.games.count > 1 else {
            randomGame = gameManager.games.first
            isShowingResult = true
            return
        }
        
        // Выбираем случайную игру
        if let randomIndex = gameManager.games.indices.randomElement() {
            randomGame = gameManager.games[randomIndex]
            
            // Добавляем небольшую задержку для анимации
            withAnimation(.easeInOut(duration: 0.3)) {
                isShowingResult = true
            }
        }
    }
    
    private func formatPlaytime(_ playtime: String) -> String {
        let playtimeLower = playtime.lowercased()
        
        // Заменяем hours на h
        let withHours = playtimeLower.replacingOccurrences(of: "hours", with: "h")
            .replacingOccurrences(of: "hour", with: "h")
        
        // Заменяем minutes на m
        return withHours.replacingOccurrences(of: "minutes", with: "m")
            .replacingOccurrences(of: "minute", with: "m")
            .replacingOccurrences(of: "mins", with: "m")
            .replacingOccurrences(of: "min", with: "m")
    }
    
    private func formatDifficulty(_ difficulty: String) -> String {
        switch difficulty.lowercased() {
        case "medium":
            return "Med"
        case "very easy":
            return "V.Easy"
        case "easy":
            return "Easy"
        case "hard":
            return "Hard"
        case "very hard":
            return "V.Hard"
        default:
            return difficulty
        }
    }
}

#Preview {
    RandomView(isPresented: .constant(true))
        .environmentObject(GameManager())

//    MainTabView()
//        .environmentObject(GameManager())
}
