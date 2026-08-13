import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, review, library, profile
}

@main
struct MyApp: App {
    @State private var selectedTab: AppTab = .home

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem { Label("Нүүр", systemImage: "house") }
                    .tag(AppTab.home)

                ReviewView()
                    .tabItem { Label("Давталт", systemImage: "rectangle.stack") }
                    .tag(AppTab.review)

                LibraryView()
                    .tabItem { Label("Сан", systemImage: "books.vertical") }
                    .tag(AppTab.library)

                ProfileView()
                    .tabItem { Label("Профайл", systemImage: "person.crop.circle") }
                    .tag(AppTab.profile)
            }
        }
        .modelContainer(for: [LearningSpace.self, Card.self])
    }
}
