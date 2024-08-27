import UIKit

final class ErrorView: UIView {
	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Methods

	func setup(model: Model) {
		self.model = model
		titleLabel.text = model.message
		retryButton.setTitle(model.retryButtonTitle, for: .normal)
		retryButton.setTitleColor(.systemBlue, for: .normal)
	}

	// MARK: - Private properties

	private let titleLabel = UILabel()
	private let retryButton = UIButton()
	private var model: Model?
}

// MARK: - Model

extension ErrorView {
	struct Model {
		let message: String
		let retryButtonTitle: String
		let onRetryTap: Action

		static func common(onTap: @escaping Action) -> Model {
			Model(
				message: L10n.Common.commonErrorMessage,
				retryButtonTitle: L10n.Common.retryLoad,
				onRetryTap: onTap
			)
		}
	}
}

// MARK: - Common init

private extension ErrorView {
	func commonInit() {
		setupUI()
		setupLayout()
	}

	func setupUI() {
		retryButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
	}

	func setupLayout() {
		let contentView = UIStackView(arrangedSubviews: [titleLabel, retryButton])
		contentView.axis = .vertical
		contentView.alignment = .center
		contentView.spacing = 16

		addSubview(contentView)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.pinCenter(to: safeAreaLayoutGuide)
		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 16),
			contentView.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: 16)
		])
	}

	@objc func handleButtonTap(_: UIControl) {
		model?.onRetryTap()
	}
}
