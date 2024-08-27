import UIKit

final class FullImagesViewControllerFactory: ViewControllerFactory {
	func make(config: [ImageInfo]) -> UIViewController {
		FullImagesViewController(images: config)
	}
}
