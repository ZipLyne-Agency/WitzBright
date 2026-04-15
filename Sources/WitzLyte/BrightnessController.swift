import Cocoa

final class BrightnessController {
    static let identityIntensity: CGFloat = 1.0
    static let minIntensity: CGFloat = 0.2

    private(set) var isEnabled = false
    private(set) var intensity: CGFloat = CGFloat(Settings.shared.intensity)
    private var overlays: [OverlayWindow] = []

    private var autoOffTimer: Timer?
    private(set) var autoOffMinutes: Int = Settings.shared.autoOffMinutes

    var onStateChange: (() -> Void)?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screensChanged() {
        if isEnabled { rebuildOverlays() }
    }

    func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        isEnabled = enabled
        if enabled {
            rebuildOverlays()
            if autoOffMinutes > 0 { scheduleAutoOff(minutes: autoOffMinutes) }
        } else {
            overlays.forEach { $0.orderOut(nil) }
            overlays.removeAll()
            autoOffTimer?.invalidate()
            autoOffTimer = nil
        }
        onStateChange?()
    }

    func setIntensity(_ value: CGFloat) {
        // Magnetic snap to identity — ±0.08 wide dead zone around 1.0 so the
        // user can reliably find "normal" by dragging near the middle.
        var v = value
        if abs(v - Self.identityIntensity) < 0.08 { v = Self.identityIntensity }
        let clamped = max(Self.minIntensity, min(maxHeadroom(), v))
        intensity = clamped
        Settings.shared.intensity = Double(clamped)
        overlays.forEach { $0.setIntensity(clamped) }
        onStateChange?()
    }

    func maxHeadroom() -> CGFloat {
        let values = NSScreen.screens.flatMap {
            [$0.maximumExtendedDynamicRangeColorComponentValue,
             $0.maximumPotentialExtendedDynamicRangeColorComponentValue]
        }
        return max(values.max() ?? 1.0, 1.5)
    }

    /// Rough nit estimate: SDR white ≈ 500 nits.
    var estimatedNits: Int { Int(Double(intensity) * 500) }

    /// "+60%" for v>1, "−40%" for v<1, "Normal" for v≈1
    var relativeLabel: String {
        let delta = Double(intensity) - 1.0
        if abs(delta) < 0.02 { return "Normal" }
        let pct = Int(round(delta * 100))
        return pct > 0 ? "+\(pct)%" : "\(pct)%"
    }

    private func rebuildOverlays() {
        overlays.forEach { $0.orderOut(nil) }
        overlays = NSScreen.screens.map { OverlayWindow(screen: $0, intensity: intensity) }
        overlays.forEach { $0.orderFrontRegardless() }
    }

    func scheduleAutoOff(minutes: Int) {
        autoOffTimer?.invalidate()
        autoOffTimer = nil
        autoOffMinutes = minutes
        Settings.shared.autoOffMinutes = minutes
        guard minutes > 0, isEnabled else { return }
        let t = Timer(timeInterval: TimeInterval(minutes * 60), repeats: false) { [weak self] _ in
            self?.setEnabled(false)
        }
        RunLoop.main.add(t, forMode: .common)
        autoOffTimer = t
    }

    func cancelAutoOff() {
        autoOffTimer?.invalidate()
        autoOffTimer = nil
    }
}
