import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: BrightnessController!
    private var menuBar: MenuBarController!
    private var powerMonitor: PowerMonitor!

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = BrightnessController()
        menuBar = MenuBarController(controller: controller)
        powerMonitor = PowerMonitor(controller: controller)

        if Settings.shared.enabledOnLaunch {
            controller.setEnabled(true)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller.setEnabled(false)
    }
}
