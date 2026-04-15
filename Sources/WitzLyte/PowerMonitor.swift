import Foundation
import IOKit.ps

final class PowerMonitor {
    private weak var controller: BrightnessController?
    private var runLoopSource: CFRunLoopSource?
    private var thermalObserver: NSObjectProtocol?

    init(controller: BrightnessController) {
        self.controller = controller

        let ctx = Unmanaged.passUnretained(self).toOpaque()
        if let src = IOPSNotificationCreateRunLoopSource({ opaque in
            guard let opaque else { return }
            Unmanaged<PowerMonitor>.fromOpaque(opaque).takeUnretainedValue().powerChanged()
        }, ctx)?.takeRetainedValue() {
            runLoopSource = src
            CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        }

        thermalObserver = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.thermalChanged() }
    }

    deinit {
        if let src = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
        }
        if let obs = thermalObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    private func powerChanged() {
        guard let controller, controller.isEnabled else { return }
        if Settings.shared.disableOnBattery && onBattery() {
            controller.setEnabled(false)
            return
        }
        if onBattery() && batteryPercent() < Settings.shared.batteryThreshold {
            controller.setEnabled(false)
        }
    }

    private func thermalChanged() {
        guard Settings.shared.disableOnThermalCritical,
              let controller, controller.isEnabled else { return }
        let state = ProcessInfo.processInfo.thermalState
        if state == .serious || state == .critical {
            controller.setEnabled(false)
        }
    }

    private func firstSourceDescription() -> [String: Any]? {
        guard let snap = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(snap)?.takeRetainedValue() as? [CFTypeRef],
              let first = list.first,
              let dict = IOPSGetPowerSourceDescription(snap, first)?.takeUnretainedValue() as? [String: Any]
        else { return nil }
        return dict
    }

    private func onBattery() -> Bool {
        guard let d = firstSourceDescription() else { return false }
        return (d[kIOPSPowerSourceStateKey] as? String) == kIOPSBatteryPowerValue
    }

    private func batteryPercent() -> Int {
        guard let d = firstSourceDescription(),
              let cur = d[kIOPSCurrentCapacityKey] as? Int,
              let mx = d[kIOPSMaxCapacityKey] as? Int, mx > 0
        else { return 100 }
        return (cur * 100) / mx
    }
}
