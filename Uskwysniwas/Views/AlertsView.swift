import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var gameManager: GameManager
    @Binding var isShowTabbar: Bool
    @State private var selectedPeriod: ReminderPeriod = .all
    @State private var isShowingAddSheet = false
    
    // Перемещаем состояние для пикеров на уровень AlertsView
    @State private var isShowingDatePicker = false
    @State private var isShowingTimePicker = false
    @State private var selectedDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Alerts")
                        .font(.custom("DaysOne-Regular", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPeriodButton(title: "All Games", isSelected: selectedPeriod == .all) {
                                selectedPeriod = .all
                            }
                            
                            FilterPeriodButton(title: "This Week", isSelected: selectedPeriod == .thisWeek) {
                                selectedPeriod = .thisWeek
                            }
                            
                            FilterPeriodButton(title: "This Month", isSelected: selectedPeriod == .thisMonth) {
                                selectedPeriod = .thisMonth
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Reminders list
                    let filteredReminders = gameManager.filterReminders(period: selectedPeriod)
                    let groupedReminders = gameManager.groupRemindersByDate()
                    
                    if filteredReminders.isEmpty {
                        VStack(spacing: 20) {
                            Spacer(minLength: 100)
                            
                            Image(systemName: "bell")
                                .font(.system(size: 60))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                            
                            Text("You haven't set any reminders yet")
                                .font(.custom("DaysOne-Regular", size: 18))
                                .foregroundColor(Color(hex: "#9CA3AF"))
                                .multilineTextAlignment(.center)
                            
                            Button {
                                withAnimation {
                                    isShowingAddSheet = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                    Text("Add Your First Reminder")
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
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Array(groupedReminders.keys.sorted()), id: \.self) { date in
                                if let reminders = groupedReminders[date], !reminders.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        // Date header
                                        Text(formatDateHeader(date))
                                            .font(.custom("DaysOne-Regular", size: 14))
                                            .foregroundColor(Color(hex: "#9CA3AF"))
                                            .padding(.horizontal, 20)
                                        
                                        // Reminders for this date
                                        ForEach(reminders) { reminder in
                                            ReminderCard(reminder: reminder) {
                                                if let index = gameManager.reminders.firstIndex(where: { $0.id == reminder.id }) {
                                                    gameManager.deleteReminder(at: index)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            
            if !gameManager.reminders.isEmpty {
                Button {
                    withAnimation {
                        isShowingAddSheet = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Add reminder")
                            .font(.custom("DaysOne-Regular", size: 16))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color(hex: "#EB4150"))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 85)
            }
            
            // Кастомный Sheet
            if isShowingAddSheet {
                CustomModalView(isShowing: $isShowingAddSheet) {
                    AddReminderSheet(
                        isShowingSheet: $isShowingAddSheet,
                        isShowingDatePicker: $isShowingDatePicker,
                        isShowingTimePicker: $isShowingTimePicker,
                        selectedDate: $selectedDate,
                        startTime: $startTime,
                        endTime: $endTime
                    )
                    .environmentObject(gameManager)
                }
            }
            
            // Пикеры поверх всего экрана
            if isShowingDatePicker {
                DatePickerOverlay(isShowing: $isShowingDatePicker, selectedDate: $selectedDate)
                    .zIndex(100)
            }
            
            if isShowingTimePicker {
                TimePickerOverlay(isShowing: $isShowingTimePicker, startTime: $startTime, endTime: $endTime)
                    .zIndex(100)
            }
        }
        .onChange(of: isShowingAddSheet) { newValue in
            isShowTabbar = !newValue
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#17182D"))
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "TODAY - \(dateFormatter.string(from: date))".uppercased()
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            return "TOMORROW - \(dateFormatter.string(from: date))".uppercased()
        } else {
            return dateFormatter.string(from: date).uppercased()
        }
    }
}

// Кастомный модальный компонент для отображения sheet
struct CustomModalView<Content: View>: View {
    @Binding var isShowing: Bool
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    let content: Content
    
    init(isShowing: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isShowing = isShowing
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Затемнённый фон
                if isShowing {
                    Color.black
                        .opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isShowing = false
                            }
                        }
                        .transition(.opacity)
                }
                
                // Модальное окно с контентом
                VStack {
                    content
                }
                .background(Color(hex: "#17182D"))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .offset(y: isShowing ? max(0, dragOffset) : geometry.size.height)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: isShowing)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isShowing = false
                                }
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
            .ignoresSafeArea()
        }
    }
}

struct FilterPeriodButton: View {
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
                .cornerRadius(12)
        }
    }
}

struct ReminderCard: View {
    let reminder: ReminderModel
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#EB4150"))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "gamecontroller")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.gameTitle)
                        .font(.custom("DaysOne-Regular", size: 16))
                        .foregroundColor(.white)
                    
                    Text(formatTimeRange(start: reminder.startTime, end: reminder.endTime))
                        .font(.custom("DaysOne-Regular", size: 14))
                        .foregroundColor(Color(hex: "#9CA3AF"))
                    
                    HStack {
                        Text("\(reminder.playersCount) players")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                }
            }
            .padding(16)
        }
        .background(Color(hex: "#2A2E46"))
        .cornerRadius(12)
    }
    
    private func formatTimeRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }
}

struct AddReminderSheet: View {
    @EnvironmentObject private var gameManager: GameManager
    @Binding var isShowingSheet: Bool
    
    // Получаем биндинги извне
    @Binding var isShowingDatePicker: Bool
    @Binding var isShowingTimePicker: Bool
    @Binding var selectedDate: Date
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    @State private var gameTitle = ""
    @State private var playersCount = 2
    @State private var selectedNotification: ReminderModel.NotificationTime = .oneDay
    
    // Добавляем состояние для отображения ошибки
    @State private var showingErrorAlert = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 16) {
                Text("New Alerts")
                    .font(.custom("DaysOne-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                VStack(spacing: 16) {
                    // Game Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Game Title")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                        
                        TextField("", text: $gameTitle)
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .background(Color(hex: "#2A2E46"))
                            .cornerRadius(12)
                            .overlay(
                                ZStack {
                                    if gameTitle.isEmpty {
                                        Text("Enter game name")
                                            .font(.custom("DaysOne-Regular", size: 16))
                                            .foregroundColor(Color(hex: "#808080"))
                                            .allowsHitTesting(false)
                                    }
                                }, alignment: .leading
                            )

                    }
                    .padding(16)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)

                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                        
                        HStack(spacing: 8) {
                            // Date Picker Button
                            Button {
                                isShowingDatePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.white)
                                        .frame(width: 12, height: 12)

                                    Text(formattedDate)
                                        .font(.custom("DaysOne-Regular", size: 14))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                                .padding(9)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#17182D"))
                                .cornerRadius(12)
                            }
                            
                            // Time Range Button
                            Button {
                                isShowingTimePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.white)
                                        .frame(width: 12, height: 12)

                                    Text(formattedTimeRange)
                                        .font(.custom("DaysOne-Regular", size: 14))
                                        .foregroundColor(.white)
                                }
                                .padding(9)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#17182D"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)

                    
                    // Players Count
                    HStack(spacing: 8) {
                        Text("Number of players")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#9CA3AF"))
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                if playersCount > 1 {
                                    playersCount -= 1
                                }
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color(hex: "#EB4150"))
                                    .clipShape(Circle())
                            }
                            
                            Text("\(playersCount)")
                                .font(.custom("DaysOne-Regular", size: 16))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(hex: "#17182D"))
                                .cornerRadius(8)
                            
                            Button {
                                playersCount += 1
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color(hex: "#EB4150"))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                    
                    // Notification Settings
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Remind me")
                                .font(.custom("DaysOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#9CA3AF"))

                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(ReminderModel.NotificationTime.allCases, id: \.self) { time in
                                Button {
                                    selectedNotification = time
                                } label: {
                                    Text(time.rawValue)
                                        .font(.custom("DaysOne-Regular", size: 14))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selectedNotification == time ? Color(hex: "#EB4150") : Color(hex: "#17182D"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                    
                    // Set Reminder Button
                    Button {
                        validateAndAddReminder()
                    } label: {
                        Text("Set Reminder")
                            .font(.custom("DaysOne-Regular", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#EB4150"))
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 30)
                }
            }
            .padding(.horizontal, 24)
            
            Button {
                withAnimation {
                    isShowingSheet = false
                }
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding(.top, 30)
                    .padding(.horizontal, 24)
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a game name")
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: startTime))-\(formatter.string(from: endTime))"
    }
    
    private func validateAndAddReminder() {
        if gameTitle.isEmpty {
            showingErrorAlert = true
            return
        }
        
        addReminder()
        withAnimation {
            isShowingSheet = false
        }
    }
    
    private func addReminder() {
        gameManager.addReminder(
            gameTitle: gameTitle,
            date: selectedDate,
            startTime: startTime,
            endTime: endTime,
            playersCount: playersCount,
            notifyBefore: selectedNotification
        )
    }
}

struct DatePickerOverlay: View {
    @Binding var isShowing: Bool
    @Binding var selectedDate: Date
    
    // Минимальная дата для выбора - текущий день
    private var minimumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 16) {
                DatePicker("", selection: $selectedDate, in: minimumDate..., displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .accentColor(Color(hex: "#EB4150"))
                    .colorScheme(.dark)
                    .padding()
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(16)
                
                Button("Done") {
                    isShowing = false
                }
                .font(.custom("DaysOne-Regular", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#EB4150"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(hex: "#17182D"))
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut, value: isShowing)
    }
}

struct TimePickerOverlay: View {
    @Binding var isShowing: Bool
    @Binding var startTime: Date
    @Binding var endTime: Date
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 16) {
                Text("Start Time")
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(.white)
                
                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .accentColor(Color(hex: "#EB4150"))
                    .colorScheme(.dark)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                
                Text("End Time")
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(.white)
                
                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .accentColor(Color(hex: "#EB4150"))
                    .colorScheme(.dark)
                    .background(Color(hex: "#2A2E46"))
                    .cornerRadius(12)
                
                Button("Done") {
                    if endTime < startTime {
                        endTime = startTime.addingTimeInterval(3600)
                    }
                    isShowing = false
                }
                .font(.custom("DaysOne-Regular", size: 16))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#EB4150"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(hex: "#17182D"))
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut, value: isShowing)
    }
}

// Структура для закругления только определенных углов
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

#Preview {
    AlertsView(isShowTabbar: .constant(false))
        .environmentObject(GameManager())
}
