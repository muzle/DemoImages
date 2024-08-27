import Foundation

final class AppFactory {
	func makeImagesFeedViewControllerFactory() -> AnyViewControllerFactory<Void> {
		let factoryDeps = ImagesFeedViewControllerFactory.Dependencies(
			makeImagesRepository: makeImagesRepository,
			makeFullImageViewControllerFactory: makeFullImageViewControllerFactory
		)
		let facotry = ImagesFeedViewControllerFactory(deps: factoryDeps)
		return facotry.asAnyViewControllerFactory()
	}
}

// MARK: - Private methods

private extension AppFactory {
	func makeFullImageViewControllerFactory() -> AnyViewControllerFactory<[ImageInfo]> {
		FullImagesViewControllerFactory()
			.asAnyViewControllerFactory()
	}

	func makeImagesRepository() -> ImagesRepository {
		ImagesRepositoryImpl(
			transport: HTTPTransportImpl(),
			authTokenRepository: AuthTokenRepositoryImpl()
		)
	}
}
