import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, review, library, profile
}

@main
struct MyApp: App {
    @State private var selectedTab: AppTab = .home
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem { Label("Нүүр", systemImage: "house.fill") }
                    .tag(AppTab.home)

                ReviewView()
                    .tabItem { Label("Давтах", systemImage: "brain.head.profile") }
                    .tag(AppTab.review)

                LibraryView()
                    .tabItem { Label("Сан", systemImage: "book.fill") }
                    .tag(AppTab.library)

                ProfileView()
                    .tabItem { Label("Профайл", systemImage: "person.fill") }
                    .tag(AppTab.profile)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [LearningSpace.self, Card.self, ReviewLog.self])
    }
}
