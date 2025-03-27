import Foundation
import UIKit
import SwiftUI
import UserNotifications

struct GameModel: Identifiable, Codable {
    var id = UUID()
    var title: String
    var genre: String
    var players: String
    var playtime: String
    var difficulty: Difficulty
    var rating: Int
    var description: String
    var comments: String
    var photoFilenames: [String]
    var dateAdded: Date
    
    enum Difficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, genre, players, playtime, difficulty, rating, description, comments, photoFilenames, dateAdded
    }
}

struct ReminderModel: Identifiable, Codable {
    var id = UUID()
    var gameTitle: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var playersCount: Int
    var notifyBefore: NotificationTime
    
    enum NotificationTime: String, Codable, CaseIterable {
        case oneDay = "1 day before"
        case threeHours = "3 hours before"
        
        var timeInterval: TimeInterval {
            switch self {
            case .oneDay:
                return 86400 // 24 часа в секундах
            case .threeHours:
                return 10800 // 3 часа в секундах
            }
        }
    }
}

struct PlayerModel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var photoFilename: String?
    var gamesPlayed: Int
    var gamesWon: Int
    
    var winRate: Int {
        if gamesPlayed == 0 {
            return 0
        }
        return Int((Double(gamesWon) / Double(gamesPlayed)) * 100)
    }
}

// Класс GameManager для управления играми
class GameManager: ObservableObject {
    @Published var games: [GameModel] = []
    @Published var reminders: [ReminderModel] = []
    @Published var players: [PlayerModel] = []
    
    private let gamesKey = "savedGames"
    private let remindersKey = "savedReminders"
    private let playersKey = "savedPlayers"
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    init() {
        loadGames()
        loadReminders()
        loadPlayers()
    }
    
    // Сохранение игр в UserDefaults
    func saveGames() {
        do {
            let data = try JSONEncoder().encode(games)
            UserDefaults.standard.set(data, forKey: gamesKey)
        } catch {
            print("Ошибка сохранения игр: \(error.localizedDescription)")
        }
    }
    
    // Загрузка игр из UserDefaults
    func loadGames() {
        if let data = UserDefaults.standard.data(forKey: gamesKey) {
            do {
                games = try JSONDecoder().decode([GameModel].self, from: data)
            } catch {
                print("Ошибка загрузки игр: \(error.localizedDescription)")
                games = []
            }
        } else {
            games = []
        }
    }
    
    // Сохранение напоминаний в UserDefaults
    func saveReminders() {
        do {
            let data = try JSONEncoder().encode(reminders)
            UserDefaults.standard.set(data, forKey: remindersKey)
        } catch {
            print("Ошибка сохранения напоминаний: \(error.localizedDescription)")
        }
    }
    
    // Загрузка напоминаний из UserDefaults
    func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: remindersKey) {
            do {
                reminders = try JSONDecoder().decode([ReminderModel].self, from: data)
            } catch {
                print("Ошибка загрузки напоминаний: \(error.localizedDescription)")
                reminders = []
            }
        } else {
            reminders = []
        }
    }
    
    // Сохранение игроков в UserDefaults
    func savePlayers() {
        do {
            let data = try JSONEncoder().encode(players)
            UserDefaults.standard.set(data, forKey: playersKey)
        } catch {
            print("Ошибка сохранения игроков: \(error.localizedDescription)")
        }
    }
    
    // Загрузка игроков из UserDefaults
    func loadPlayers() {
        if let data = UserDefaults.standard.data(forKey: playersKey) {
            do {
                players = try JSONDecoder().decode([PlayerModel].self, from: data)
            } catch {
                print("Ошибка загрузки игроков: \(error.localizedDescription)")
                players = []
            }
        } else {
            players = []
        }
    }
    
    // Добавление нового игрока
    func addPlayer(name: String, description: String, photo: UIImage? = nil, gamesPlayed: Int = 0, gamesWon: Int = 0) -> PlayerModel {
        var photoFilename: String? = nil
        
        // Сохраняем фотографию, если она есть
        if let photo = photo {
            let filename = "player_\(UUID().uuidString).jpg"
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            if let data = photo.jpegData(compressionQuality: 0.7) {
                do {
                    try data.write(to: fileURL)
                    photoFilename = filename
                } catch {
                    print("Ошибка сохранения фото игрока: \(error.localizedDescription)")
                }
            }
        }
        
        let newPlayer = PlayerModel(
            name: name,
            description: description,
            photoFilename: photoFilename,
            gamesPlayed: gamesPlayed,
            gamesWon: gamesWon
        )
        
        players.append(newPlayer)
        savePlayers()
        
        return newPlayer
    }
    
    // Обновление данных игрока
    func updatePlayer(id: UUID, name: String, description: String, photo: UIImage? = nil, gamesPlayed: Int, gamesWon: Int) {
        if let index = players.firstIndex(where: { $0.id == id }) {
            var photoFilename = players[index].photoFilename
            
            // Обновляем фотографию, если она передана
            if let photo = photo {
                // Удаляем старую фотографию, если она была
                if let oldFilename = photoFilename {
                    let oldFileURL = documentsDirectory.appendingPathComponent(oldFilename)
                    try? FileManager.default.removeItem(at: oldFileURL)
                }
                
                // Сохраняем новую фотографию
                let filename = "player_\(UUID().uuidString).jpg"
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                
                if let data = photo.jpegData(compressionQuality: 0.7) {
                    do {
                        try data.write(to: fileURL)
                        photoFilename = filename
                    } catch {
                        print("Ошибка сохранения фото игрока: \(error.localizedDescription)")
                    }
                }
            }
            
            // Обновляем данные игрока
            players[index] = PlayerModel(
                id: id,
                name: name,
                description: description,
                photoFilename: photoFilename,
                gamesPlayed: gamesPlayed,
                gamesWon: gamesWon
            )
            
            savePlayers()
        }
    }
    
    // Удаление игрока
    func deletePlayer(at index: Int) {
        // Удаляем фотографию игрока, если она есть
        if let photoFilename = players[index].photoFilename {
            let fileURL = documentsDirectory.appendingPathComponent(photoFilename)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        players.remove(at: index)
        savePlayers()
    }
    
    // Получение фотографии игрока
    func loadPlayerPhoto(filename: String?) -> UIImage {
        guard let filename = filename else {
            return UIImage(systemName: "person.crop.circle") ?? UIImage()
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            return image
        }
        
        return UIImage(systemName: "person.crop.circle") ?? UIImage()
    }
    
    // Увеличение счетчика игр для игрока
    func incrementGamesPlayed(for playerId: UUID) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].gamesPlayed += 1
            savePlayers()
        }
    }
    
    // Увеличение счетчика побед для игрока
    func incrementGamesWon(for playerId: UUID) {
        if let index = players.firstIndex(where: { $0.id == playerId }) {
            players[index].gamesWon += 1
            savePlayers()
        }
    }
    
    // Добавление нового напоминания
    func addReminder(gameTitle: String, date: Date, startTime: Date, endTime: Date, playersCount: Int, notifyBefore: ReminderModel.NotificationTime) {
        let newReminder = ReminderModel(
            gameTitle: gameTitle,
            date: date,
            startTime: startTime,
            endTime: endTime,
            playersCount: playersCount,
            notifyBefore: notifyBefore
        )
        
        reminders.append(newReminder)
        saveReminders()
        
        // Планируем уведомление
        scheduleNotification(for: newReminder)
    }
    
    // Удаление напоминания
    func deleteReminder(at index: Int) {
        let reminder = reminders[index]
        
        // Отменяем запланированное уведомление
        cancelNotification(for: reminder)
        
        reminders.remove(at: index)
        saveReminders()
    }
    
    // Планирование уведомления
    private func scheduleNotification(for reminder: ReminderModel) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Запрашиваем разрешение на отправку уведомлений, если еще не делали этого
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка запроса разрешения на уведомления: \(error.localizedDescription)")
                return
            }
            
            if granted {
                self.createAndScheduleNotification(for: reminder)
            }
        }
    }
    
    // Создание и планирование уведомления
    private func createAndScheduleNotification(for reminder: ReminderModel) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // Создаем контент уведомления
        let content = UNMutableNotificationContent()
        content.title = "Game Reminder: \(reminder.gameTitle)"
        content.body = "Your game starts \(formatTimeRange(start: reminder.startTime, end: reminder.endTime)) with \(reminder.playersCount) players"
        content.sound = UNNotificationSound.default
        
        // Создаем комбинированную дату для уведомления
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: reminder.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminder.startTime)
        
        var notificationDateComponents = DateComponents()
        notificationDateComponents.year = dateComponents.year
        notificationDateComponents.month = dateComponents.month
        notificationDateComponents.day = dateComponents.day
        notificationDateComponents.hour = timeComponents.hour
        notificationDateComponents.minute = timeComponents.minute
        
        // Применяем смещение для уведомления (за день или за 3 часа)
        if let notificationDate = calendar.date(from: notificationDateComponents) {
            let notifyDate = notificationDate.addingTimeInterval(-reminder.notifyBefore.timeInterval)
            let finalComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notifyDate)
            
            // Создаем триггер для уведомления
            let trigger = UNCalendarNotificationTrigger(dateMatching: finalComponents, repeats: false)
            
            // Создаем запрос на уведомление
            let request = UNNotificationRequest(
                identifier: reminder.id.uuidString,
                content: content,
                trigger: trigger
            )
            
            // Добавляем запрос в центр уведомлений
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Ошибка добавления уведомления: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Отмена уведомления
    private func cancelNotification(for reminder: ReminderModel) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString])
    }
    
    // Форматирование диапазона времени
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "at \(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
    
    // Получение напоминаний, отсортированных по дате
    func getSortedReminders() -> [ReminderModel] {
        return reminders.sorted { $0.date < $1.date }
    }
    
    // Фильтрация напоминаний по периоду
    func filterReminders(period: ReminderPeriod) -> [ReminderModel] {
        let sortedReminders = getSortedReminders()
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .all:
            return sortedReminders
        case .thisWeek:
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: now)!
            return sortedReminders.filter { $0.date <= endOfWeek }
        case .thisMonth:
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: now)!
            return sortedReminders.filter { $0.date <= endOfMonth }
        }
    }
    
    // Группировка напоминаний по дате
    func groupRemindersByDate() -> [Date: [ReminderModel]] {
        let sortedReminders = getSortedReminders()
        var groupedReminders: [Date: [ReminderModel]] = [:]
        
        for reminder in sortedReminders {
            // Получаем только компонент даты без времени
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: reminder.date)
            if let dateKey = calendar.date(from: dateComponents) {
                if groupedReminders[dateKey] == nil {
                    groupedReminders[dateKey] = []
                }
                groupedReminders[dateKey]?.append(reminder)
            }
        }
        
        return groupedReminders
    }
    
    // Добавление новой игры
    func addGame(title: String, genre: String, players: String, playtime: String, difficulty: GameModel.Difficulty, rating: Int, description: String, comments: String, photos: [UIImage]) {
        var photoFilenames: [String] = []
        
        // Сохраняем фотографии в документах
        for (index, photo) in photos.enumerated() {
            let filename = "\(UUID().uuidString)_\(index).jpg"
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            
            if let data = photo.jpegData(compressionQuality: 0.7) {
                do {
                    try data.write(to: fileURL)
                    photoFilenames.append(filename)
                } catch {
                    print("Ошибка сохранения фото: \(error.localizedDescription)")
                }
            }
        }
        
        // Создаем новую игру
        let newGame = GameModel(
            title: title,
            genre: genre,
            players: players,
            playtime: playtime,
            difficulty: difficulty,
            rating: rating,
            description: description,
            comments: comments,
            photoFilenames: photoFilenames,
            dateAdded: Date()
        )
        
        // Добавляем игру в список и сохраняем
        games.append(newGame)
        saveGames()
    }
    
    // Загрузка фотографии по имени файла
    func loadPhoto(filename: String) -> UIImage {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            return image
        }
        return UIImage(systemName: "photo") ?? UIImage()
    }
    
    // Удаление игры
    func deleteGame(at index: Int) {
        // Удаляем фотографии игры
        let game = games[index]
        for filename in game.photoFilenames {
            let fileURL = documentsDirectory.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        // Удаляем игру из списка и сохраняем
        games.remove(at: index)
        saveGames()
    }
    
    // Поиск игр по тексту
    func searchGames(query: String) -> [GameModel] {
        if query.isEmpty {
            return games
        }
        
        return games.filter { game in
            let searchableText = "\(game.title) \(game.genre) \(game.description)".lowercased()
            return searchableText.contains(query.lowercased())
        }
    }
    
    // Получение уникальных жанров из всех игр
    func getAllGenres() -> [String] {
        var genres = Set<String>()
        for game in games {
            genres.insert(game.genre)
        }
        return Array(genres).sorted()
    }
    
    // Получение уникальных вариантов количества игроков
    func getAllPlayerOptions() -> [String] {
        var options = Set<String>()
        for game in games {
            options.insert(game.players)
        }
        return Array(options).sorted()
    }
}

// UI Image для отображения фотографий игры
struct GameImage: View {
    let filename: String
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        Image(uiImage: gameManager.loadPhoto(filename: filename))
            .resizable()
            .scaledToFill()
    }
}

// Перечисление для фильтрации напоминаний
enum ReminderPeriod {
    case all, thisWeek, thisMonth
}

extension GameModel {
    static let mockGames: [GameModel] = [
        GameModel(
            title: "Ticket to Ride",
            genre: "Strategy",
            players: "2-5",
            playtime: "45min",
            difficulty: .easy,
            rating: 5,
            description: "A board game about building train routes across North America",
            comments: "Great game for strategy and adventure",
            photoFilenames: [],
            dateAdded: Date()
        ),
        GameModel(
            title: "Catan",
            genre: "Strategy",
            players: "3-4",
            playtime: "60min",
            difficulty: .medium,
            rating: 4,
            description: "A board game about building settlements and roads",
            comments: "Fun game for strategy and family",
            photoFilenames: [],
            dateAdded: Date()
        ),
        GameModel(
            title: "Pandemic",
            genre: "Cooperative",
            players: "2-4",
            playtime: "45min",
            difficulty: .hard,
            rating: 3,
            description: "A cooperative game about fighting a global pandemic",
            comments: "Challenging game for cooperative and strategy",
            photoFilenames: [],
            dateAdded: Date()
        )
    ]
} 