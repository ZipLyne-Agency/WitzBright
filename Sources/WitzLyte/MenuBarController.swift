import Cocoa
import ServiceManagement

final class MenuBarController: NSObject {
    private let controller: BrightnessController
    private let statusItem: NSStatusItem
    private var menu: NSMenu!

    private weak var intensitySlider: NSSlider?
    private weak var intensityLabel: NSTextField?
    private weak var autoOffItem: NSMenuItem?

    init(controller: BrightnessController) {
        self.controller = controller
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        buildMenu()
        statusItem.menu = menu
        controller.onStateChange = { [weak self] in self?.syncUI() }
        syncUI()
    }

    private func buildMenu() {
        menu = NSMenu()
        menu.autoenablesItems = false

        let toggle = NSMenuItem(title: "Enable Witz Lyte",
                                action: #selector(toggleEnabled),
                                keyEquivalent: "b")
        toggle.target = self
        toggle.keyEquivalentModifierMask = [.command, .option, .shift]
        menu.addItem(toggle)

        menu.addItem(.separator())

        let header = NSMenuItem(title: "BRIGHTNESS", action: nil, keyEquivalent: "")
        header.isEnabled = false
        header.attributedTitle = sectionHeader("BRIGHTNESS · dim ← → boost")
        menu.addItem(header)

        menu.addItem(makeSliderItem())

        let resetItem = NSMenuItem(title: "Reset to Normal",
                                   action: #selector(resetIntensity),
                                   keyEquivalent: "0")
        resetItem.target = self
        resetItem.keyEquivalentModifierMask = [.command, .option, .shift]
        menu.addItem(resetItem)

        menu.addItem(.separator())

        let autoOff = NSMenuItem(title: "Auto-off: Off", action: nil, keyEquivalent: "")
        autoOff.submenu = buildAutoOffSubmenu()
        menu.addItem(autoOff)
        autoOffItem = autoOff

        menu.addItem(.separator())

        addCheckable(menu, title: "Enable on launch",
                     checked: Settings.shared.enabledOnLaunch,
                     action: #selector(toggleEnableOnLaunch))

        addCheckable(menu, title: "Launch at login",
                     checked: isLaunchAtLoginEnabled,
                     action: #selector(toggleLaunchAtLogin))

        addCheckable(menu, title: "Disable on battery",
                     checked: Settings.shared.disableOnBattery,
                     action: #selector(toggleBattery))

        addCheckable(menu, title: "Disable on thermal warning",
                     checked: Settings.shared.disableOnThermalCritical,
                     action: #selector(toggleThermal))

        menu.addItem(.separator())

        let about = NSMenuItem(title: "About Witz Lyte", action: #selector(showAbout), keyEquivalent: "")
        about.target = self
        menu.addItem(about)

        let quit = NSMenuItem(title: "Quit Witz Lyte", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    private func makeSliderItem() -> NSMenuItem {
        let item = NSMenuItem()
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 280, height: 36))

        let minIcon = iconView("moon.fill")
        minIcon.frame = NSRect(x: 14, y: 10, width: 16, height: 16)
        view.addSubview(minIcon)

        let slider = NSSlider(value: Double(controller.intensity),
                              minValue: Double(BrightnessController.minIntensity),
                              maxValue: Double(controller.maxHeadroom()),
                              target: self,
                              action: #selector(intensityChanged(_:)))
        slider.frame = NSRect(x: 34, y: 10, width: 176, height: 16)
        slider.isContinuous = true
        slider.numberOfTickMarks = 3
        slider.allowsTickMarkValuesOnly = false
        slider.tickMarkPosition = .below
        view.addSubview(slider)
        intensitySlider = slider

        let maxIcon = iconView("sun.max.fill")
        maxIcon.frame = NSRect(x: 214, y: 10, width: 16, height: 16)
        view.addSubview(maxIcon)

        let label = NSTextField(labelWithString: controller.relativeLabel)
        label.frame = NSRect(x: 234, y: 9, width: 44, height: 18)
        label.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabelColor
        label.alignment = .right
        view.addSubview(label)
        intensityLabel = label

        item.view = view
        return item
    }

    private func buildAutoOffSubmenu() -> NSMenu {
        let sub = NSMenu()
        let options: [(String, Int)] = [
            ("Off", 0), ("15 minutes", 15), ("30 minutes", 30),
            ("1 hour", 60), ("2 hours", 120)
        ]
        for (title, minutes) in options {
            let item = NSMenuItem(title: title,
                                  action: #selector(setAutoOff(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.tag = minutes
            item.state = controller.autoOffMinutes == minutes ? .on : .off
            sub.addItem(item)
        }
        return sub
    }

    private func sectionHeader(_ text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: [
            .font: NSFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: NSColor.tertiaryLabelColor,
            .kern: 0.4
        ])
    }

    private func iconView(_ systemName: String) -> NSImageView {
        let img = NSImage(systemSymbolName: systemName, accessibilityDescription: nil)
        let v = NSImageView(image: img ?? NSImage())
        v.contentTintColor = .secondaryLabelColor
        return v
    }

    private func addCheckable(_ menu: NSMenu, title: String, checked: Bool, action: Selector) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.state = checked ? .on : .off
        menu.addItem(item)
    }

    private var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    private func syncUI() {
        let on = controller.isEnabled
        let sym = on ? "sun.max.fill" : "sun.max"
        statusItem.button?.image = NSImage(systemSymbolName: sym, accessibilityDescription: "Witz Lyte")
        statusItem.button?.toolTip = on
            ? "Witz Lyte · \(controller.relativeLabel) · ~\(controller.estimatedNits) nits"
            : "Witz Lyte (off)"

        menu.items.first?.title = on ? "Disable Witz Lyte" : "Enable Witz Lyte"

        intensitySlider?.maxValue = Double(controller.maxHeadroom())
        intensitySlider?.doubleValue = Double(controller.intensity)
        intensityLabel?.stringValue = controller.relativeLabel

        if controller.autoOffMinutes > 0 {
            let mins = controller.autoOffMinutes
            let label = mins >= 60 ? "\(mins / 60)h" : "\(mins)m"
            autoOffItem?.title = "Auto-off: \(label)"
        } else {
            autoOffItem?.title = "Auto-off: Off"
        }
        autoOffItem?.submenu?.items.forEach {
            $0.state = $0.tag == controller.autoOffMinutes ? .on : .off
        }
    }

    @objc private func toggleEnabled() { controller.setEnabled(!controller.isEnabled) }

    @objc private func intensityChanged(_ sender: NSSlider) {
        controller.setIntensity(CGFloat(sender.doubleValue))
        // After the snap-to-normal dead zone, push the slider back to the
        // snapped value so the thumb physically parks at 1.0.
        sender.doubleValue = Double(controller.intensity)
        intensityLabel?.stringValue = controller.relativeLabel
    }

    @objc private func resetIntensity() {
        controller.setIntensity(BrightnessController.identityIntensity)
    }

    @objc private func setAutoOff(_ sender: NSMenuItem) {
        controller.scheduleAutoOff(minutes: sender.tag)
        syncUI()
    }

    @objc private func toggleEnableOnLaunch(_ sender: NSMenuItem) {
        Settings.shared.enabledOnLaunch.toggle()
        sender.state = Settings.shared.enabledOnLaunch ? .on : .off
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if isLaunchAtLoginEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            sender.state = isLaunchAtLoginEnabled ? .on : .off
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't update login item"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    @objc private func toggleBattery(_ sender: NSMenuItem) {
        Settings.shared.disableOnBattery.toggle()
        sender.state = Settings.shared.disableOnBattery ? .on : .off
    }

    @objc private func toggleThermal(_ sender: NSMenuItem) {
        Settings.shared.disableOnThermalCritical.toggle()
        sender.state = Settings.shared.disableOnThermalCritical ? .on : .off
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Witz Lyte"
        alert.informativeText = """
        Unlock your Mac's XDR display brightness — and dim below the OS floor.

        Crafted by ZipLyne · ziplyne.agency
        MIT License · github.com/ZipLyne-Agency/WitzLyte
        """
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc private func quitApp() { NSApp.terminate(nil) }
}
