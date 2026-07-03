import Foundation

public enum VolumeEjectFeedbackState: Equatable, Sendable {
    case started
    case succeeded
    case failed(errorDescription: String)
}

public enum VolumeEjectFeedback {
    public static func message(for state: VolumeEjectFeedbackState, volumeName: String) -> String {
        switch state {
        case .started:
            return "Ejecting \(volumeName)..."
        case .succeeded:
            return "Ejected \(volumeName)"
        case .failed(let errorDescription):
            return "Could not eject \(volumeName): \(errorDescription)"
        }
    }
}
