import Foundation

protocol AuthTokenRepository {
	func token() throws -> String
}
