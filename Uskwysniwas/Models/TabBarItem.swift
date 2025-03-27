import SwiftUI

enum TabBarItem: String, CaseIterable {
    case games = "Games"
    case alerts = "Alerts"
    case random = "Random"
    case players = "Players" 
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .games:
            return "games_icon"
        case .alerts:
            return "alerts_icon"
        case .random:
            return "random_icon"
        case .players:
            return "players_icon"
        case .settings:
            return "settings_icon"
        }
    }
} 