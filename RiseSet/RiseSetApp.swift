import SwiftUI
import MenuBarExtraAccess

@main
struct RiseSetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var sunTimesModel = SunTimesModel()
    @State private var isMenuPresented = false

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(sunTimesModel)
        } label: {
            MenuBarLabel()
                .environmentObject(sunTimesModel)
        }
        .menuBarExtraStyle(.window)
        .menuBarExtraAccess(isPresented: $isMenuPresented) { statusItem in
            appDelegate.statusItem = statusItem
            appDelegate.sunTimesModel = sunTimesModel
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var sunTimesModel: SunTimesModel?
    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            self?.handleRightClick(event: event)
            return event
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func handleRightClick(event: NSEvent) {
        guard let button = statusItem?.button else { return }
        guard let buttonWindow = button.window else { return }

        let locationInScreen = event.locationInWindow
        let buttonFrameInScreen = buttonWindow.convertToScreen(button.frame)

        if buttonFrameInScreen.contains(NSPoint(x: locationInScreen.x + buttonWindow.frame.origin.x,
                                                  y: locationInScreen.y + buttonWindow.frame.origin.y)) {
            showContextMenu()
        }
    }

    private func showContextMenu() {
        guard let button = statusItem?.button else { return }

        let menu = NSMenu()

        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 5), in: button)
    }

    @objc func refresh() {
        sunTimesModel?.refresh()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
