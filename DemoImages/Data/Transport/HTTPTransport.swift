import Combine
import Foundation

protocol HTTPTransport {
	func fetch(request: URLRequest) -> AnyPublisher<Data, Error>
}

extension HTTPTransport {
	func fetch<T: Decodable>(request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
		fetch(request: request)
			.decode(type: T.self, decoder: decoder)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}
}

final class HTTPTransportImpl: HTTPTransport {
	// MARK: - Init

	init(session: URLSession = .shared) {
		self.session = session
	}

	// MARK: - HTTPTransport

	func fetch(request: URLRequest) -> AnyPublisher<Data, Error> {
		session.dataTaskPublisher(for: request)
			.map(\.data)
			.mapError { $0 as Error }
			.eraseToAnyPublisher()
	}

	// MARK: - Private properties

	private let session: URLSession
}
