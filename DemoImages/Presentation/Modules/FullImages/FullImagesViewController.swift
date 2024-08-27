import UIKit

final class FullImagesViewController: UIViewController {
	// MARK: - Init

	init(images: [ImageInfo]) {
		self.images = images
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		commonInit()
	}

	// MARK: - Private properties

	private let images: [ImageInfo]
	private let pagesController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
	private let closeButton = UIButton()
	private var controllersCache = [Int: UIViewController]()
}

// MARK: - UIPageViewControllerDataSource

extension FullImagesViewController: UIPageViewControllerDataSource {
	func pageViewController(
		_: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		let index = controllersCache.first(where: { $0.value === viewController })?.key ?? 0
		return makeController(for: index - 1)
	}

	func pageViewController(
		_: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		let index = controllersCache.first(where: { $0.value === viewController })?.key ?? 0
		return makeController(for: index + 1)
	}
}

// MARK: - Common init

private extension FullImagesViewController {
	func commonInit() {
		setupUI()
		setupLayout()
	}

	func setupUI() {
		view.backgroundColor = .systemBackground

		pagesController.dataSource = self
		if let controller = makeController(for: 0) {
			pagesController.setViewControllers([controller], direction: .forward, animated: false)
		}

		closeButton.addTarget(self, action: #selector(handleCLoseButtonTap), for: .touchUpInside)
		closeButton.setTitle(L10n.Common.close, for: .normal)
		closeButton.setTitleColor(.systemBlue, for: .normal)
	}

	func setupLayout() {
		addChild(pagesController)
		pagesController.view.frame = view.frame
		view.addSubview(pagesController.view)
		pagesController.didMove(toParent: self)

		view.addSubview(closeButton)
		closeButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
			closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
		])
	}

	func makeController(for index: Int) -> UIViewController? {
		if let controller = controllersCache[index] {
			return controller
		}
		guard let image = images[safe: index] else { return nil }
		let controller = FullImageViewController(imageInfo: image)
		controllersCache[index] = controller
		return controller
	}

	@objc func handleCLoseButtonTap(_: UIControl) {
		dismiss(animated: true)
	}
}
