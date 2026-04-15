import Cocoa

final class OverlayWindow: NSWindow {
    private let metalView: EDRMetalView

    init(screen: NSScreen, intensity: CGFloat) {
        self.metalView = EDRMetalView(frame: NSRect(origin: .zero, size: screen.frame.size))
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        setFrame(screen.frame, display: false)
        contentView = metalView
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .screenSaver
        hidesOnDeactivate = false
        animationBehavior = .none
        ignoresMouseEvents = true
        isMovable = false
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
        sharingType = .none
        metalView.setIntensity(intensity)
    }

    func setIntensity(_ value: CGFloat) {
        metalView.setIntensity(value)
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
