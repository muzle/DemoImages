import UIKit

final class FullImageViewController: UIViewController {
	// MARK: - Init

	init(imageInfo: ImageInfo) {
		self.imageInfo = imageInfo
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

	private let imageInfo: ImageInfo
	private let imageView = UIImageView()
	private let activityIndicator = UIActivityIndicatorView(style: .large)
	private let retryButton = UIButton()
	private weak var errorView: ErrorView?
}

// MARK: - Common init

private extension FullImageViewController {
	func commonInit() {
		setupUI()
		setupLayout()
		fetchImage()
	}

	func setupUI() {
		imageView.contentMode = .scaleAspectFit
	}

	func setupLayout() {
		view.addSubview(imageView)
		imageView.pin(to: view.safeAreaLayoutGuide)

		view.addSubview(activityIndicator)
		activityIndicator.pinCenter(to: view.safeAreaLayoutGuide)
	}

	func fetchImage() {
		errorView?.removeFromSuperview()
		activityIndicator.startAnimating()
		imageView.setImage(with: imageInfo.image.url) { [weak self] result in
			self?.activityIndicator.stopAnimating()
			if let error = result.error {
				self?.handleFetchImageError(error)
			}
		}
	}

	func handleFetchImageError(_: Error) {
		let errorView = ErrorView()
		let model = ErrorView.Model.common { [weak self] in
			self?.fetchImage()
		}
		errorView.setup(model: model)
		view.addSubview(errorView)
		errorView.pin(to: view.safeAreaLayoutGuide)
	}
}
