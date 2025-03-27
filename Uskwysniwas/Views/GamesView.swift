import SwiftUI

struct GamesView: View {
    @EnvironmentObject private var gameManager: GameManager
    @State private var searchText = ""
    @Binding var isTabbarVisible: Bool
    
    // Состояние для фильтрации
    @State private var selectedFilter: FilterCategory = .none
    @State private var selectedGenre: String = "All"
    @State private var selectedPlayers: String = "All"
    @State private var selectedDuration: String = "All"
    @State private var selectedDifficulty: String = "All"
    
    // Доступные значения для фильтров
    private let genres = ["All", "Strategy", "Party Games", "Card", "Board", "Family", "Action"]
    private let playersOptions = ["All", "1-2", "2-4", "3-6", "4+", "6+"]
    private let durations = ["All", "< 15 min", "15-30 min", "30-60 min", "1-2 hours", "2+ hours"]
    private let difficulties = ["All", "Easy", "Medium", "Hard"]
    
    // Перечисление для категорий фильтрации
    enum FilterCategory {
        case none, genre, players, duration, difficulty
    }
    
    // Фильтрованные игры с учетом поиска и фильтров
    var filteredGames: [GameModel] {
        var games = gameManager.searchGames(query: searchText)
        
        // Применяем дополнительные фильтры
        if selectedGenre != "All" {
            games = games.filter { $0.genre.contains(selectedGenre) }
        }
        
        if selectedPlayers != "All" {
            games = games.filter { matchesPlayerCount($0.players, filter: selectedPlayers) }
        }
        
        if selectedDuration != "All" {
            games = games.filter { matchesDuration($0.playtime, filter: selectedDuration) }
        }
        
        if selectedDifficulty != "All" {
            games = games.filter { $0.difficulty.rawValue == selectedDifficulty }
        }
        
        return games
    }
    
    // Проверка для поисковых результатов
    var hasSearchResults: Bool {
        return !filteredGames.isEmpty
    }
    
    // Проверка есть ли игры вообще
    var hasGames: Bool {
        return !gameManager.games.isEmpty
    }
    
    // Проверка активен ли поиск или фильтры
    var isFilteringActive: Bool {
        return !searchText.isEmpty || 
               selectedGenre != "All" || 
               selectedPlayers != "All" || 
               selectedDuration != "All" || 
               selectedDifficulty != "All"
    }
    
    var body: some View {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("My Games")
                            .font(.custom("DaysOne-Regular", size: 24))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Search bar and filters
                        VStack(spacing: 16) {
                            HStack {
                                searchBar
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FilterButton(title: "Genre", isSelected: selectedFilter == .genre) {
                                        if selectedFilter == .genre {
                                            selectedFilter = .none
                                            selectedGenre = "All"
                                        } else {
                                            selectedFilter = .genre
                                        }
                                    }
                                    
                                    FilterButton(title: "Players", isSelected: selectedFilter == .players) {
                                        if selectedFilter == .players {
                                            selectedFilter = .none
                                            selectedPlayers = "All"
                                        } else {
                                            selectedFilter = .players
                                        }
                                    }
                                    
                                    FilterButton(title: "Duration", isSelected: selectedFilter == .duration) {
                                        if selectedFilter == .duration {
                                            selectedFilter = .none
                                            selectedDuration = "All"
                                        } else {
                                            selectedFilter = .duration
                                        }
                                    }
                                    
                                    FilterButton(title: "Difficulty", isSelected: selectedFilter == .difficulty) {
                                        if selectedFilter == .difficulty {
                                            selectedFilter = .none
                                            selectedDifficulty = "All"
                                        } else {
                                            selectedFilter = .difficulty
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Фильтр выбора опций
                            if selectedFilter != .none {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        switch selectedFilter {
                                        case .genre:
                                            ForEach(genres, id: \.self) { genre in
                                                FilterOptionButton(title: genre, isSelected: selectedGenre == genre) {
                                                    selectedGenre = genre
                                                }
                                            }
                                            
                                        case .players:
                                            ForEach(playersOptions, id: \.self) { option in
                                                FilterOptionButton(title: option, isSelected: selectedPlayers == option) {
                                                    selectedPlayers = option
                                                }
                                            }
                                            
                                        case .duration:
                                            ForEach(durations, id: \.self) { duration in
                                                FilterOptionButton(title: duration, isSelected: selectedDuration == duration) {
                                                    selectedDuration = duration
                                                }
                                            }
                                            
                                        case .difficulty:
                                            ForEach(difficulties, id: \.self) { difficulty in
                                                FilterOptionButton(title: difficulty, isSelected: selectedDifficulty == difficulty) {
                                                    selectedDifficulty = difficulty
                                                }
                                            }
                                            
                                        default:
                                            EmptyView()
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.top, -8)
                            }
                        }
                        
                        // Game list
                        if !hasGames {
                            // Нет игр вообще
                            emptyGamesView
                        } else if isFilteringActive && !hasSearchResults {
                            // Поиск активен, но нет результатов
                            noSearchResultsView
                        } else {
                            // Список игр
                            VStack(spacing: 12) {
                                ForEach(filteredGames) { game in
                                    GameCard(game: game, gameManager: gameManager)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                if let index = gameManager.games.firstIndex(where: { $0.id == game.id }) {
                                                    gameManager.deleteGame(at: index)
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                if hasGames && !isFilteringActive {
                    HStack {
                        Spacer()
                        NavigationLink {
                            AddGameView(isTabbarVisible: $isTabbarVisible)
                                .environmentObject(gameManager)
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Add game")
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
                }
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#17182D"))
            .navigationBarHidden(true)
    }
    
    // Вид для пустого поиска
    private var noSearchResultsView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#9CA3AF"))
            
            Text("No games match your search")
                .font(.custom("DaysOne-Regular", size: 18))
                .foregroundColor(Color(hex: "#9CA3AF"))
                .multilineTextAlignment(.center)
            
            Button {
                searchText = ""
                selectedGenre = "All"
                selectedPlayers = "All"
                selectedDuration = "All"
                selectedDifficulty = "All"
                selectedFilter = .none
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .bold))
                    Text("Clear Filters")
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
    
    // Вид для случая, когда нет игр вообще
    private var emptyGamesView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            
            Image(systemName: "gamecontroller")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#9CA3AF"))
            
            Text("You haven't added any games yet")
                .font(.custom("DaysOne-Regular", size: 18))
                .foregroundColor(Color(hex: "#9CA3AF"))
                .multilineTextAlignment(.center)
            
            NavigationLink {
                AddGameView(isTabbarVisible: $isTabbarVisible)
                    .environmentObject(gameManager)
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                    Text("Add Your First Game")
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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "#9CA3AF"))
                .padding(.leading, 12)
                        
            TextField("", text: $searchText)
                .font(.custom("DaysOne-Regular", size: 16))
                .foregroundColor(.white)
                .background(Color(hex: "#2A2E46"))
                .padding(.vertical, 16)
                .cornerRadius(12)
                .overlay(
                    ZStack {
                        if searchText.isEmpty {
                            Text("Search games...")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(Color(hex: "#808080"))
                                .allowsHitTesting(false)
                        }
                    }, alignment: .leading
                )

            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "#9CA3AF"))
                }
                .padding(.trailing, 16)
            }
        }
        .background(Color(hex: "#2A2E46"))
        .cornerRadius(12)
    }
    
    // Функции для сопоставления фильтров
    private func matchesPlayerCount(_ playerCount: String, filter: String) -> Bool {
        if filter == "All" { return true }
        
        let playerRange = playerCount.lowercased()
        
        switch filter {
        case "1-2":
            return playerRange.contains("1-2") || playerRange.contains("1") || playerRange.contains("2")
        case "2-4":
            return playerRange.contains("2-4") || playerRange.contains("3") || playerRange.contains("4")
        case "3-6":
            return playerRange.contains("3-6") || playerRange.contains("4") || playerRange.contains("5") || playerRange.contains("6")
        case "4+":
            return playerRange.contains("4") || playerRange.contains("5") || playerRange.contains("6") || playerRange.contains("+")
        case "6+":
            return playerRange.contains("6") || playerRange.contains("7") || playerRange.contains("8") || playerRange.contains("+")
        default:
            return false
        }
    }
    
    private func matchesDuration(_ duration: String, filter: String) -> Bool {
        if filter == "All" { return true }
        
        let durationLower = duration.lowercased()
        
        switch filter {
        case "< 15 min":
            return durationLower.contains("<15") || durationLower.contains("<10") || durationLower.contains("< 15")
        case "15-30 min":
            return durationLower.contains("15-30") || durationLower.contains("20") || durationLower.contains("25")
        case "30-60 min":
            return durationLower.contains("30-60") || durationLower.contains("45") || durationLower.contains("30")
        case "1-2 hours":
            return durationLower.contains("1-2") || durationLower.contains("hour") || durationLower.contains("1h")
        case "2+ hours":
            return durationLower.contains("2+") || durationLower.contains("3") || durationLower.contains("hours")
        default:
            return false
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("DaysOne-Regular", size: 14))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color(hex: "#EB4150") : Color(hex: "#2A2E46"))
                .cornerRadius(20)
        }
    }
}

struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("DaysOne-Regular", size: 12))
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color(hex: "#EB4150") : Color(hex: "#17182D"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#9CA3AF"), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

struct GameCard: View {
    let game: GameModel
    let gameManager: GameManager
    
    // Вычисляемое свойство для сокращенного времени игры
    private var formattedPlaytime: String {
        let playtime = game.playtime.lowercased()
        
        // Заменяем hours на h
        let withHours = playtime.replacingOccurrences(of: "hours", with: "h")
            .replacingOccurrences(of: "hour", with: "h")
        
        // Заменяем minutes на m
        return withHours.replacingOccurrences(of: "minutes", with: "m")
            .replacingOccurrences(of: "minute", with: "m")
            .replacingOccurrences(of: "mins", with: "m")
            .replacingOccurrences(of: "min", with: "m")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Game image
                if !game.photoFilenames.isEmpty {
                    GameImage(filename: game.photoFilenames[0], gameManager: gameManager)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "#EB4150"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.white)
                                .font(.system(size: 30))
                        )
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(game.title)
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(.white)
                    
                    Text(game.genre)
                        .font(.custom("DaysOne-Regular", size: 12))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                    
                    HStack(spacing: 16) {
                        // Players
                        HStack(spacing: 4) {
                            Image("person")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                            
                            Text(game.players)
                                .font(.custom("DaysOne-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        
                        // Duration
                        HStack(spacing: 4) {
                            Image("clock")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                            
                            Text(formattedPlaytime)
                                .font(.custom("DaysOne-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                        
                        // Difficulty
                        HStack(spacing: 4) {
                            Image("star")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                            
                            Text(game.difficulty.rawValue)
                                .font(.custom("DaysOne-Regular", size: 12))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(Color(hex: "#2A2E46"))
        .cornerRadius(12)
    }
}

#Preview {
    GamesView(isTabbarVisible: .constant(true))
        .environmentObject(GameManager())
}
