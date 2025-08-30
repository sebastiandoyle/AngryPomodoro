import Foundation
import AVFoundation
import MediaPlayer
import UIKit

final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private let volumeView = MPVolumeView(frame: .zero)

    private init() {
        volumeView.isHidden = true
        DispatchQueue.main.async {
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first {
                self.volumeView.frame = CGRect(x: -1000, y: -1000, width: 0, height: 0)
                window.addSubview(self.volumeView)
            }
        }
    }

    func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func setSystemVolumeToMax() {
        // Best-effort: find the slider inside MPVolumeView and set to max
        DispatchQueue.main.async {
            if let slider = self.volumeView.subviews.compactMap({ $0 as? UISlider }).first {
                slider.value = 1.0
            }
        }
    }

    func playAlertSound() {
        configureSession()
        setSystemVolumeToMax()
        guard let url = Bundle.main.url(forResource: "annoying-buzzer-74499", withExtension: "mp3") else {
            print("Alert sound not found in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 1.0
            player?.numberOfLoops = -1 // loop until explicitly stopped
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    func stopAlertSound() {
        guard let player else { return }
        if player.isPlaying {
            player.stop()
        }
        self.player = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Ignore deactivation errors
        }
    }
}
