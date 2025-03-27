import SwiftUI
import SafariServices
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Binding var isTabbarVisible: Bool
    @State private var showClearDataAlert = false
    @State private var showNotificationsDisabledAlert = false
    @State private var notificationsEnabled = false
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Заголовок
                Text("Settings")
                    .font(.custom("DaysOne-Regular", size: 24))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Секция Уведомления
                VStack(alignment: .leading, spacing: 20) {
                    Text("Notifications")
                        .font(.custom("DaysOne-Regular", size: 18))
                        .foregroundColor(.white)
                    
                    // Переключатель уведомлений
                    HStack {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#17182D"))
                                    .frame(width: 30, height: 30)
                                
                                Image("bell")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 14, height: 14)
                            }
                            
                            Text("Game Reminders")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#EB4150")))
                    }
                    .padding(16)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Секция О приложении
                VStack(alignment: .leading, spacing: 20) {
                    Text("About")
                        .font(.custom("DaysOne-Regular", size: 18))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        // Версия
                        HStack {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#17182D"))
                                        .frame(width: 30, height: 30)
                                    
                                    Image("version")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 14, height: 14)
                                }
                                
                                Text("Version")
                                    .font(.custom("DaysOne-Regular", size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("1.0.0")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                        }
                        .padding(16)
                        .background(Color(hex: "#2A2E46"))
                        .cornerRadius(12)
                        
                        // Условия использования
                        Button {
                            openURL("https://www.google.com")
                        } label: {
                            HStack {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#17182D"))
                                            .frame(width: 30, height: 30)
                                        
                                        Image("terms")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                            .frame(width: 14, height: 14)
                                    }
                                    
                                    Text("Terms of Service")
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            .padding(16)
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                        }
                        
                        // Помощь и поддержка
                        Button {
                            openURL("https://www.google.com")
                        } label: {
                            HStack {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#17182D"))
                                            .frame(width: 30, height: 30)
                                        
                                        Image("help")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.white)
                                            .frame(width: 14, height: 14)
                                    }
                                    
                                    Text("Help & Support")
                                        .font(.custom("DaysOne-Regular", size: 16))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14))
                            }
                            .padding(16)
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Секция Данные
                VStack(alignment: .leading, spacing: 20) {
                    Text("Data")
                        .font(.custom("DaysOne-Regular", size: 18))
                        .foregroundColor(.white)
                    
                    Button {
                        showClearDataAlert = true
                    } label: {
                        HStack {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#17182D"))
                                        .frame(width: 30, height: 30)
                                    
                                    Image("data")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.white)
                                        .frame(width: 14, height: 14)
                                }
                                
                                Text("Your data")
                                    .font(.custom("DaysOne-Regular", size: 16))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Text("Clear")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#EB4150"))
                        }
                        .padding(16)
                        .background(Color(hex: "#2A2E46"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#17182D"))
        .navigationBarHidden(true)
        .alert(isPresented: $showClearDataAlert) {
            Alert(
                title: Text("Clear All Data"),
                message: Text("Do you want to delete all your games, players and reminders? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete All"), action: clearAllData),
                secondaryButton: .cancel()
            )
        }
        .alert("Notifications Disabled", isPresented: $showNotificationsDisabledAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("All game reminders notifications will be disabled.")
        }
        .onAppear {
            // Проверяем текущий статус разрешений на уведомления
            checkNotificationStatus()
        }
        .onChange(of: notificationsEnabled) { newValue in
            if newValue {
                // Если уведомления включены, запрашиваем разрешение
                requestNotificationPermission()
            } else {
                // Если уведомления выключены, показываем алерт
                showNotificationsDisabledAlert = true
                // Отменяем все запланированные уведомления
                cancelAllNotifications()
            }
        }
    }
    
    // Функция для открытия URL
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
    
    // Функция для очистки всех данных
    private func clearAllData() {
        // Очищаем все игры, игроков и алерты
        gameManager.games = []
        gameManager.players = []
        gameManager.reminders = []
        
        // Сохраняем пустые данные
        gameManager.saveGames()
        gameManager.savePlayers()
        gameManager.saveReminders()
        
        // Очищаем директорию с фотографиями
        clearPhotoDirectory()
    }
    
    // Функция для очистки директории с фотографиями
    private func clearPhotoDirectory() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                        includingPropertiesForKeys: nil,
                                                                        options: .skipsHiddenFiles)
            for fileURL in fileURLs where fileURL.pathExtension == "jpg" {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Ошибка при очистке директории с фотографиями: \(error.localizedDescription)")
        }
    }
    
    // Функция для проверки текущего статуса разрешений на уведомления
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Функция для запроса разрешения на отправку уведомлений
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                notificationsEnabled = granted
            }
        }
    }
    
    // Функция для отмены всех запланированных уведомлений
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

#Preview {
    SettingsView(isTabbarVisible: .constant(true))
        .environmentObject(GameManager())
        .preferredColorScheme(.dark)
} 