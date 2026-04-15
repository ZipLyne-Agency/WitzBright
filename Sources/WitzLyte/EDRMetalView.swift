import AppKit
import Metal
import QuartzCore

final class EDRMetalView: NSView {
    private var metalLayer: CAMetalLayer!
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var timer: Timer?
    private var brightnessMultiplier: Double = 1.0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    deinit { timer?.invalidate() }

    private func setup() {
        wantsLayer = true

        guard let dev = MTLCreateSystemDefaultDevice() else { return }
        device = dev
        commandQueue = dev.makeCommandQueue()

        let ml = CAMetalLayer()
        ml.device = dev
        ml.pixelFormat = .rgba16Float
        ml.wantsExtendedDynamicRangeContent = true
        ml.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
        ml.isOpaque = false
        ml.framebufferOnly = true
        ml.allowsNextDrawableTimeout = false
        ml.contentsScale = window?.backingScaleFactor ?? 2.0
        ml.backgroundColor = CGColor.clear
        ml.displaySyncEnabled = true
        ml.presentsWithTransaction = true
        // The core trick: compositor does result = overlay × underlying.
        // v=1.0 is identity; v>1.0 scales every on-screen pixel into EDR headroom.
        ml.compositingFilter = "multiplyBlendMode"
        ml.actions = [
            "contents": NSNull(),
            "bounds": NSNull(),
            "position": NSNull()
        ]
        metalLayer = ml
        layer = ml

        startRendering()
    }

    func setIntensity(_ intensity: CGFloat) {
        brightnessMultiplier = Double(intensity)
        render()
    }

    private func startRendering() {
        render()
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in self?.render() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func render() {
        guard let metalLayer,
              let drawable = metalLayer.nextDrawable(),
              let buf = commandQueue?.makeCommandBuffer() else { return }

        let desc = MTLRenderPassDescriptor()
        desc.colorAttachments[0].texture = drawable.texture
        desc.colorAttachments[0].loadAction = .clear
        let v = brightnessMultiplier
        desc.colorAttachments[0].clearColor = MTLClearColor(red: v, green: v, blue: v, alpha: 1)
        desc.colorAttachments[0].storeAction = .store

        guard let enc = buf.makeRenderCommandEncoder(descriptor: desc) else { return }
        enc.endEncoding()

        buf.commit()
        buf.waitUntilScheduled()
        drawable.present()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let scale = window?.backingScaleFactor {
            metalLayer?.contentsScale = scale
        }
    }

    override func layout() {
        super.layout()
        guard let metalLayer else { return }
        metalLayer.frame = bounds
        let scale = metalLayer.contentsScale
        metalLayer.drawableSize = CGSize(
            width: bounds.width * scale,
            height: bounds.height * scale
        )
        render()
    }
}
