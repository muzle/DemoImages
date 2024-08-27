import Combine
import Foundation

protocol ImagesRepository {
	func fetch(
		query: String,
		count: Int
	) -> AnyPublisher<ImagesInfo, Error>
}
