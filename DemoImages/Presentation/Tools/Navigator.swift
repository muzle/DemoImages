import UIKit

protocol Navigator {
	func present(controller: UIViewController)
	func push(controller: UIViewController)
	func dismiss()
}

final class NavigatorProxy: Navigator {
	var ownerController: UIViewController?

	// MARK: - Navigator

	func present(controller: UIViewController) {
		assert(ownerController != nil)
		ownerController?.present(controller, animated: true)
	}

	func push(controller: UIViewController) {
		assert(ownerController?.navigationController != nil)
		ownerController?.navigationController?.pushViewController(controller, animated: true)
	}

	func dismiss() {
		assert(ownerController != nil)
		ownerController?.dismiss(animated: true)
	}
}
