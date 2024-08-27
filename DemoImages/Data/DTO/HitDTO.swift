import Foundation

// MARK: - Hit

struct HitDTO: Codable {
	let id: Int
	let pageURL: String
	let type: String
	let tags: String
	let previewURL: URL
	let previewWidth, previewHeight: Int
	let webformatURL: URL
	let webformatWidth, webformatHeight: Int
	let largeImageURL: URL
	let imageWidth, imageHeight, imageSize, views: Int
	let downloads, collections, likes, comments: Int
	let userID: Int
	let user: String
	let userImageURL: String

	// swiftlint:disable line_length
	enum CodingKeys: String, CodingKey {
		case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, collections, likes, comments
		case userID = "user_id"
		case user, userImageURL
	}
}
