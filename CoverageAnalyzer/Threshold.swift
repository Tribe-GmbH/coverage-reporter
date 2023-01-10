import Foundation

public enum ThresholdValidationError: String, Error, CustomStringConvertible {
    case tooBig = "Threshold is too big (max allowed value is 100)"
    case tooSmall = "Threshold is too small (minimum value should be 0)"

    public var description: String {
        return self.rawValue
    }
}

internal func validateThreshold(_ threshold: Float) -> Result<Float, Error> {
    if threshold > 100 {
        return .failure(ThresholdValidationError.tooBig)
    }

    if threshold < 0 {
        return .failure(ThresholdValidationError.tooSmall)
    }

    return .success(threshold)
}
