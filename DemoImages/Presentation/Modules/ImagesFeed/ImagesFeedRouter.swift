import Foundation

final class ImagesFeedRouter {
	// MARK: - Init

	init(
		fullImageViewControllerFactory: AnyViewControllerFactory<[ImageInfo]>,
		navigator: Navigator
	) {
		self.fullImageViewControllerFactory = fullImageViewControllerFactory
		self.navigator = navigator
	}

	// MARK: - Methods

	func openFullImage(images: [ImageInfo]) {
		let controller = fullImageViewControllerFactory.make(config: images)
		controller.modalPresentationStyle = .fullScreen
		navigator.present(controller: controller)
	}

	// MARK: - Private properties

	private let fullImageViewControllerFactory: AnyViewControllerFactory<[ImageInfo]>
	private let navigator: Navigator
}
