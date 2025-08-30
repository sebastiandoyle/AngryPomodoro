import Foundation
import AVFoundation

final class TorchFlasher {
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "TorchFlasherQueue")
    private var isOn: Bool = false

    func start() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        stop()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(120)) // ~8 Hz
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.toggleTorch()
        }
        self.timer = timer
        timer.resume()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        setTorch(false)
    }

    private func toggleTorch() {
        setTorch(!isOn)
    }

    private func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if on {
                try device.setTorchModeOn(level: 1.0)
            } else {
                device.torchMode = .off
            }
            device.unlockForConfiguration()
            isOn = on
        } catch {
            // Ignore errors; torch not available or not permitted
        }
    }
}
