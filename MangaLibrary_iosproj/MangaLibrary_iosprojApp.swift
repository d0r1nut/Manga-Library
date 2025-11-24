import SwiftUI
import Firebase

@main
struct MangaLibraryAppApp: App {
    init() {
        // Ensure GoogleService-Info.plist is added to the target
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AuthViewModel.shared)
                .environmentObject(MangaViewModel.shared)
        }
    }
}
