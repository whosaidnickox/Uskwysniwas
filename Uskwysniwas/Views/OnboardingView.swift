import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var currentPage = 0
    @Binding var onboardingCompleted: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(OnboardingModel.data) { item in
                    OnboardingPageView(model: item,
                                       onNext: {
                        if item.id == OnboardingModel.data.count - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    },
                                       onSkip: {
                        completeOnboarding()
                    })
                    .tag(item.id)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(hex: "#17182D"))
        .iukisonubas()
        .onAppear() {
            print("ghes")
        }
    }
    
    // Функция для завершения онбординга
    private func completeOnboarding() {
        // Устанавливаем статус завершения онбординга
        onboardingCompleted = true
        // Сохраняем в UserDefaults
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }
}

#Preview {
    OnboardingView(onboardingCompleted: .constant(false))
        .environmentObject(GameManager())
}

struct OnboardingPageView: View {
    let model: OnboardingModel
    let onNext: () -> Void
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .center) {
                Text(model.pageNumber)
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(Color(hex: "#9CA3AF"))
                
                HStack {
                    Spacer()
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(.custom("DaysOne-Regular", size: 14))
                            .foregroundColor(Color(hex: "#EB4150"))
                    }
                }
                .padding(.horizontal, 25)
            }
            .padding(.bottom, 24)

            Text(model.title)
                .font(.custom("DaysOne-Regular", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 44)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            
            Image(model.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#EB4150"))
                        .frame(width: 40, height: 40)
                    
                    Image(model.iconName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 25, height: 20)
                }
                
                Text(model.description)
                    .font(.custom("DaysOne-Regular", size: 14))
                    .foregroundColor(Color(hex: "#9CA3AF"))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding(16)
            .background(Color(hex: "#2A2E46"))
            .cornerRadius(12)
            .padding(.horizontal, 24)
            
            Button(action: onNext) {
                Text(model.buttonTitle)
                    .font(.custom("DaysOne-Regular", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color(hex: "#EB4150"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#17182D"))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
