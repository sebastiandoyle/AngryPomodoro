import Foundation
import CoreMotion
import Combine

final class MotionMonitor {
    private let motionManager = CMMotionManager()
    private let subject = CurrentValueSubject<Bool, Never>(false)
    var isFaceDownPublisher: AnyPublisher<Bool, Never> { subject.eraseToAnyPublisher() }

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.2
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion = motion else { return }
            let z = motion.gravity.z
            // In iOS device coordinates: face-down ~ +1, face-up ~ -1
            let faceDown = z > 0.7
            self?.subject.send(faceDown)
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
