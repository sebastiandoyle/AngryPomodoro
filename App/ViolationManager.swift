import Foundation

final class ViolationManager {
    private let audio = AudioManager.shared
    private let torch = TorchFlasher()

    func triggerObnoxiousAlert() {
        torch.start()
        audio.playAlertSound()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            self?.torch.stop()
        }
    }

    func stopAll() {
        torch.stop()
        audio.stopAlertSound()
    }
}
