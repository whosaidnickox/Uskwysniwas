import Foundation

struct OnboardingModel: Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
    let iconName: String
    let buttonTitle: String
    let pageNumber: String
}

extension OnboardingModel {
    static let data: [OnboardingModel] = [
        OnboardingModel(
            id: 0,
            title: "Welcome to Game \nCatalog!",
            description: "Create a list of your favorite games, and add details like genre, number of players, and playtime!",
            imageName: "onboarding1",
            iconName: "onboarding1_icon",
            buttonTitle: "Next",
            pageNumber: "1/3"
        ),
        OnboardingModel(
            id: 1,
            title: "Alerts",
            description: "Never forget a game night! Set alerts for upcoming games with your friends.",
            imageName: "onboarding2",
            iconName: "onboarding2_icon",
            buttonTitle: "Next",
            pageNumber: "2/3"
        ),
        OnboardingModel(
            id: 2,
            title: "Random Game Picker",
            description: "Can't decide what to play? Let us pick a random game from your collection!",
            imageName: "onboarding3",
            iconName: "onboarding3_icon",
            buttonTitle: "Start!",
            pageNumber: "3/3"
        )
    ]
} 
