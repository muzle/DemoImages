import Combine
import Foundation

final class ImagesRepositoryImpl: ImagesRepository {
	// MARK: - Init

	init(transport: HTTPTransport, authTokenRepository: AuthTokenRepository) {
		self.transport = transport
		self.authTokenRepository = authTokenRepository
	}

	// MARK: - ImagesRepository

	func fetch(
		query: String,
		count: Int
	) -> AnyPublisher<ImagesInfo, Error> {
		do {
			let request = try makeRequest(query: query, count: count)
			return transport.fetch(request: request)
				.map(Self.mapDomain(dto:))
				.eraseToAnyPublisher()
		} catch {
			return .result(.failure(error))
		}
	}

	// MARK: - Private properties

	private let transport: HTTPTransport
	private let authTokenRepository: AuthTokenRepository
}

// MARK: - Private methods

private extension ImagesRepositoryImpl {
	func makeRequest(query: String, count: Int) throws -> URLRequest {
		let token = try authTokenRepository.token()
		guard var components = URLComponents(string: GlobalConstants.imagesBaseURL) else { throw URLError(.badURL) }
		components.queryItems = [
			URLQueryItem(name: "q", value: query),
			URLQueryItem(name: "key", value: token),
			URLQueryItem(name: "per_page", value: "\(count)")
		]
		guard let url = components.url else { throw URLError(.badURL) }
		return URLRequest(url: url)
	}

	static func mapDomain(dto: HitsDTO) -> ImagesInfo {
		var infos = [ImageInfo]()
		for hit in dto.hits {
			let info = ImageInfo(
				id: hit.id,
				tags: hit.tags.split(separator: ", ").map { String($0) },
				preview: RemoteImage(url: hit.previewURL, size: CGSize(width: hit.previewWidth, height: hit.previewHeight)),
				image: RemoteImage(url: hit.largeImageURL, size: CGSize(width: hit.imageWidth, height: hit.imageHeight))
			)
			infos.append(info)
		}
		return ImagesInfo(
			availableCount: dto.totalHits,
			infos: infos
		)
	}
}
