import SwiftUI

@main
struct RiseSetApp: App {
    @StateObject private var sunTimesModel = SunTimesModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(sunTimesModel)
        } label: {
            MenuBarLabel()
                .environmentObject(sunTimesModel)
        }
        .menuBarExtraStyle(.window)
    }
}
