import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?

	func scene(
		_ scene: UIScene,
		willConnectTo _: UISceneSession,
		options _: UIScene.ConnectionOptions
	) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		window = UIWindow(windowScene: windowScene)
		let controllerFactory = appFactory.makeImagesFeedViewControllerFactory()
		let navigationController = UINavigationController(rootViewController: controllerFactory.make())
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}

	// MARK: - Private properties

	private lazy var appFactory = AppFactory()
}
