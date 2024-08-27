import UIKit

protocol ViewControllerFactory {
	associatedtype Config
	func make(config: Config) -> UIViewController
}

extension ViewControllerFactory where Config == Void {
	func make() -> UIViewController {
		make(config: ())
	}
}

extension ViewControllerFactory {
	func asAnyViewControllerFactory() -> AnyViewControllerFactory<Config> {
		AnyViewControllerFactory(makeMethod: make(config:))
	}
}

final class AnyViewControllerFactory<T>: ViewControllerFactory {
	// MARK: - Types

	typealias MakeMethod = (T) -> UIViewController

	// MARK: - Init

	init(makeMethod: @escaping MakeMethod) {
		self.makeMethod = makeMethod
	}

	// MARK: - ViewControllerFactory

	func make(config: T) -> UIViewController {
		makeMethod(config)
	}

	// MARK: - Private properties

	private let makeMethod: MakeMethod
}
