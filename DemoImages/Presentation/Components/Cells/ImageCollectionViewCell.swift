import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func prepareForReuse() {
		imageView.image = nil
		tagsLabel.text = ""
	}

	// MARK: - Methods

	func setup(model: Model) {
		activityIndicator.startAnimating()
		guard let url = model.imageURL else { return }
		tagsLabel.text = model.tags
		imageView.setImage(with: url) { [activityIndicator] in
			if $0.error == nil { activityIndicator.stopAnimating() }
		}
	}

	static func calculateTagsLabelHeight(for model: Model, containerWidth: CGFloat) -> CGFloat {
		let constraintRect = CGSize(width: containerWidth, height: .greatestFiniteMagnitude)
		let boundingBox = model.tags.boundingRect(
			with: constraintRect,
			options: [.usesLineFragmentOrigin, .usesFontLeading],
			attributes: [.font: Constatns.font],
			context: nil
		)
		return boundingBox.height
	}

	// MARK: - Private properties

	private let imageView = UIImageView()
	private let tagsLabel = UILabel()
	private let activityIndicator = UIActivityIndicatorView(style: .large)
}

// MARK: - Model

extension ImageCollectionViewCell {
	struct Model {
		let imageURL: URL?
		let tags: String
		let imageSize: CGSize
	}
}

// MARK: - Common init

private extension ImageCollectionViewCell {
	func commonInit() {
		setupUI()
		setupLayuot()
	}

	func setupUI() {
		tagsLabel.font = Constatns.font
		tagsLabel.textColor = .secondaryLabel
		tagsLabel.numberOfLines = 0
		tagsLabel.textAlignment = .center

		imageView.contentMode = .scaleAspectFit
	}

	func setupLayuot() {
		[imageView, tagsLabel, activityIndicator].forEach {
			contentView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

			tagsLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constatns.tagsLabelInsets.top),
			tagsLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: Constatns.tagsLabelInsets.left),
			tagsLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -Constatns.tagsLabelInsets.right),
			tagsLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Constatns.tagsLabelInsets.bottom),

			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
}

// MARK: - Constants

private extension ImageCollectionViewCell {
	enum Constatns {
		static let font = UIFont.systemFont(ofSize: 12)
		static let tagsLabelInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
	}
}
