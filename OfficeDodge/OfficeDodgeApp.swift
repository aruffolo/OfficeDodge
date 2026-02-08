import AppFeature
import SwiftUI

@main
struct OfficeDodgeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
