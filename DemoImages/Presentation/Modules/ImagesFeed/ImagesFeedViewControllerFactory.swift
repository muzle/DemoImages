import UIKit

final class ImagesFeedViewControllerFactory: ViewControllerFactory {
	// MARK: - Init

	init(deps: Dependencies) {
		self.deps = deps
	}

	// MARK: - ViewControllerFactory

	func make(config _: Void) -> UIViewController {
		let navigator = NavigatorProxy()
		let router = ImagesFeedRouter(
			fullImageViewControllerFactory: deps.makeFullImageViewControllerFactory(),
			navigator: navigator
		)
		let viewModel = ImagesFeedViewModel(
			imagesReportiory: deps.makeImagesRepository(),
			router: router
		)
		let controller = ImagesFeedViewController(viewModel: viewModel)
		navigator.ownerController = controller
		return controller
	}

	// MARK: - Private properties

	private let deps: Dependencies
}

// MARK: - Dependencies

extension ImagesFeedViewControllerFactory {
	struct Dependencies {
		let makeImagesRepository: () -> ImagesRepository
		let makeFullImageViewControllerFactory: () -> AnyViewControllerFactory<[ImageInfo]>
	}
}
