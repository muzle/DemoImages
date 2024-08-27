import Foundation

final class AuthTokenRepositoryImpl: AuthTokenRepository {
	func token() throws -> String { GlobalConstants.authToken }
}
