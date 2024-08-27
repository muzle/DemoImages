import Foundation

extension Result {
	var error: Failure? {
		switch self {
		case .success: nil
		case let .failure(failure): failure
		}
	}
}
