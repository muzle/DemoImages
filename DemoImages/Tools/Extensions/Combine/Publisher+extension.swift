import Combine
import Foundation

extension Publisher {
	static func result(_ result: Result<Output, Failure>) -> AnyPublisher<Output, Failure> {
		Deferred {
			Future { completion in
				completion(result)
			}
		}
		.eraseToAnyPublisher()
	}

	func sink(
		receiveValue: @escaping Handler<Output>,
		receiveError: @escaping Handler<Failure> = { _ in },
		finished: @escaping Action = {}
	) -> AnyCancellable {
		sink(
			receiveCompletion: { completion in
				switch completion {
				case .finished:
					finished()
				case let .failure(error):
					receiveError(error)
				}
			},
			 receiveValue: receiveValue
		)
	}
}
