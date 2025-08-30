import Foundation
import AVFoundation

final class PermissionsManager {
    static let shared = PermissionsManager()

    private init() {}

    func requestCameraIfNeeded(completion: ((Bool) -> Void)? = nil) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion?(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion?(granted) }
            }
        case .denied, .restricted:
            completion?(false)
        @unknown default:
            completion?(false)
        }
    }
}
