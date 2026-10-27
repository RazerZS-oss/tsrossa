import SwiftUI
import AppKit

@main
struct TsrossaMacApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
