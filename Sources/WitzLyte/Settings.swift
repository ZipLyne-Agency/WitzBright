import Foundation

final class Settings {
    static let shared = Settings()
    private let d = UserDefaults.standard

    var intensity: Double {
        get { d.object(forKey: "intensity") as? Double ?? 2.0 }
        set { d.set(newValue, forKey: "intensity") }
    }

    var enabledOnLaunch: Bool {
        get { d.bool(forKey: "enabledOnLaunch") }
        set { d.set(newValue, forKey: "enabledOnLaunch") }
    }

    var disableOnBattery: Bool {
        get { d.bool(forKey: "disableOnBattery") }
        set { d.set(newValue, forKey: "disableOnBattery") }
    }

    var batteryThreshold: Int {
        get { d.object(forKey: "batteryThreshold") as? Int ?? 20 }
        set { d.set(newValue, forKey: "batteryThreshold") }
    }

    var disableOnThermalCritical: Bool {
        get { d.object(forKey: "disableOnThermalCritical") as? Bool ?? true }
        set { d.set(newValue, forKey: "disableOnThermalCritical") }
    }

    var autoOffMinutes: Int {
        get { d.object(forKey: "autoOffMinutes") as? Int ?? 0 }
        set { d.set(newValue, forKey: "autoOffMinutes") }
    }
}
