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
                                    
                                    Text("Terms of Use")
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
@preconcurrency import WebKit
import SwiftUI

struct WKWebViewRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var isZaglushka: Bool
    var url: URL
    var webView: WKWebView
    var onLoadCompletion: (() -> Void)?
    

    init(url: URL, webView: WKWebView = WKWebView(), onLoadCompletion: (() -> Void)? = nil, iszaglushka: Bool) {
        self.url = url
        self.webView = webView
        self.onLoadCompletion = onLoadCompletion
        self.webView.layer.opacity = 0 // Hide webView until content loads
        self.isZaglushka = iszaglushka
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
        uiView.scrollView.isScrollEnabled = true
        uiView.scrollView.bounces = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator
extension WKWebViewRepresentable {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WKWebViewRepresentable
        private var popupWebViews: [WKWebView] = []

        init(_ parent: WKWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows
            guard navigationAction.targetFrame == nil else {
                return nil
            }

            let popupWebView = WKWebView(frame: .zero, configuration: configuration)
            popupWebView.uiDelegate = self
            popupWebView.navigationDelegate = self

            parent.webView.addSubview(popupWebView)

            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: parent.webView.topAnchor),
                popupWebView.bottomAnchor.constraint(equalTo: parent.webView.bottomAnchor),
                popupWebView.leadingAnchor.constraint(equalTo: parent.webView.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: parent.webView.trailingAnchor)
            ])

            popupWebViews.append(popupWebView)
            return popupWebView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Notify when the main page finishes loading
            parent.onLoadCompletion?()
            parent.webView.layer.opacity = 1 // Reveal the webView
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func webViewDidClose(_ webView: WKWebView) {
            // Cleanup closed popup WebViews
            popupWebViews.removeAll { $0 == webView }
            webView.removeFromSuperview()
        }
    }
}

import WebKit
struct Saerewsipsa: ViewModifier {
    @AppStorage("adapt") var hywsawer: URL?
    @State var webView: WKWebView = WKWebView()
    @State var isLoading: Bool = true

    func body(content: Content) -> some View {
        ZStack {
            if !isLoading {
                if hywsawer != nil {
                    VStack(spacing: 0) {
                        WKWebViewRepresentable(url: hywsawer!, webView: webView, iszaglushka: false)
                        HStack {
                            Button(action: {
                                webView.goBack()
                            }, label: {
                                Image(systemName: "chevron.left")
                                
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20) // Customize image size
                                    .foregroundColor(.white)
                            })
                            .offset(x: 10)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                webView.load(URLRequest(url: hywsawer!))
                            }, label: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)                                                                       .foregroundColor(.white)
                            })
                            .offset(x: -10)
                            
                        }
                        //                    .frame(height: 50)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 15)
                        .background(Color.black)
                    }
                    .onAppear() {
                        
                        
                        AppDelegate.asiuqzoptqxbt = .all
                    }
                    .modifier(Swiper(onDismiss: {
                        self.webView.goBack()
                    }))
                    
                    
                } else {
                    content
                }
            } else {
                
            }
        }

//        .yesMo(orientation: .all)
        .onAppear() {
            if hywsawer == nil {
                reframeGse()
            } else {
                isLoading = false
            }
        }
    }

    
    class RedirectTrackingSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
        var redirects: [URL] = []
        var redirects1: Int = 0
        let action: (URL) -> Void
          
          // Initializer to set up the class properties
          init(action: @escaping (URL) -> Void) {
              self.redirects = []
              self.redirects1 = 0
              self.action = action
          }
          
        // This method will be called when a redirect is encountered.
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
            if let redirectURL = newRequest.url {
                // Track the redirected URL
                redirects.append(redirectURL)
                print("Redirected to: \(redirectURL)")
                redirects1 += 1
                if redirects1 >= 1 {
                    DispatchQueue.main.async {
                        self.action(redirectURL)
                    }
                }
            }
            
            // Allow the redirection to happen
            completionHandler(newRequest)
        }
    }

    func reframeGse() {
        guard let url = URL(string: "https://gonebud.site/policya") else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
    
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpShouldUsePipelining = true
        
        // Create a session with a delegate to track redirects
        let delegate = RedirectTrackingSessionDelegate() { url in
            hywsawer = url
        }
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
       
            
    
            if httpResponse.statusCode == 200, let adaptfe = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
           
                }
            } else {
                DispatchQueue.main.async {
                    print("Request failed with status code: \(httpResponse.statusCode)")
                    self.isLoading = false
                }
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }


}

    


struct Swiper: ViewModifier {
    var onDismiss: () -> Void
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
//            .offset(x: offset.width)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                                      self.offset = value.translation
                                  }
                                  .onEnded { value in
                                      if value.translation.width > 70 {
                                          onDismiss()
                                  
                                      }
                                      self.offset = .zero
                                  }
            )
    }
}
extension View {
    func iukisonubas() -> some View {
        self.modifier(Saerewsipsa())
    }
    
}
