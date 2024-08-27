import Combine
import UIKit

final class ImagesFeedViewController: UIViewController {
	// MARK: - Init

	init(viewModel: ImagesFeedViewModel) {
		self.viewModel = viewModel
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

	override func willTransition(
		to newCollection: UITraitCollection,
		with coordinator: any UIViewControllerTransitionCoordinator
	) {
		super.willTransition(to: newCollection, with: coordinator)
		coordinator.animate { [collectionViewFlowLayout] _ in
			collectionViewFlowLayout.invalidateLayout()
		}
	}

	// MARK: - Private properties

	private let viewModel: ImagesFeedViewModel
	private var cancellables = Set<AnyCancellable>()
	private var dataSource = [ImageCollectionViewCell.Model]()
	private var cachedCellMaxHeight = [IndexPath: CGFloat]()

	private let collectionViewFlowLayout = UICollectionViewFlowLayout()
	private let activityIndicator = UIActivityIndicatorView(style: .large)
	private let searchResultController = UISearchController(searchResultsController: nil)
	private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
	private weak var errorView: ErrorView?
}

// MARK: - UISearchResultsUpdating

extension ImagesFeedViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		viewModel.onTextChanged(text: searchController.searchBar.text.orEmpty)
	}
}

// MARK: - UICollectionViewDataSource

extension ImagesFeedViewController: UICollectionViewDataSource {
	func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
		dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeue(ImageCollectionViewCell.self, for: indexPath)
		cell.setup(model: dataSource[indexPath.row])
		return cell
	}

	func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewModel.onItemSelected(indexPath: indexPath)
	}
}

// MARK: - ImagesFeedFlowLayoutDelegate

extension ImagesFeedViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout _: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		var contentWidth = collectionView.bounds.width - collectionViewFlowLayout.sectionInset.horizontal
		contentWidth -= collectionViewFlowLayout.minimumInteritemSpacing
		let width = (contentWidth / 2).rounded(.down)

		if let height = cachedCellMaxHeight[indexPath] {
			return CGSize(width: width, height: height)
		}

		let lhsIndexPath: IndexPath
		let rhsIndexPath: IndexPath

		if indexPath.item % 2 == 0 {
			lhsIndexPath = indexPath
			rhsIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
		} else {
			lhsIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
			rhsIndexPath = indexPath
		}

		let height = max(
			calculateCellHeight(for: lhsIndexPath, maxWidth: width),
			calculateCellHeight(for: rhsIndexPath, maxWidth: width)
		)

		cachedCellMaxHeight[lhsIndexPath] = height
		cachedCellMaxHeight[rhsIndexPath] = height

		return CGSize(width: width, height: height)
	}
}

// MARK: - Common init

private extension ImagesFeedViewController {
	func commonInit() {
		setupUI()
		setupLayuot()
		bind()
	}

	func setupUI() {
		view.backgroundColor = .systemBackground

		navigationItem.title = L10n.ImagesFeed.navigationTitle
		navigationItem.searchController = searchResultController

		searchResultController.searchResultsUpdater = self
		searchResultController.searchBar.placeholder = L10n.ImagesFeed.fieldPlaceholder
		searchResultController.obscuresBackgroundDuringPresentation = false

		collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		collectionView.register(ImageCollectionViewCell.self)
		collectionView.dataSource = self
		collectionView.delegate = self
	}

	func setupLayuot() {
		view.addSubviews(collectionView, activityIndicator)
		collectionView.pin(to: view.safeAreaLayoutGuide)
		activityIndicator.pinCenter(to: view.safeAreaLayoutGuide)
	}

	func bind() {
		viewModel.state
			.sink(receiveValue: { [weak self] state in
				self?.handle(state: state)
			})
			.store(in: &cancellables)
	}

	func handle(state: ImagesFeedViewState) {
		let clean = { [self] in
			activityIndicator.stopAnimating()
			errorView?.removeFromSuperview()
			dataSource.removeAll()
			cachedCellMaxHeight.removeAll()
			collectionView.reloadData()
		}

		switch state {
		case .idle:
			return
		case .loading:
			clean()
			activityIndicator.startAnimating()
		case let .error(model):
			clean()
			showErrorView(with: model)
		case let .dataSource(array):
			clean()
			dataSource = array
			collectionView.reloadData()
		}
	}

	func showErrorView(with model: ErrorView.Model) {
		let view = ErrorView()
		view.setup(model: model)
		self.view.addSubview(view)
		view.pin(to: self.view.safeAreaLayoutGuide)
		self.errorView = view
	}

	func calculateCellHeight(for indexPath: IndexPath, maxWidth: CGFloat) -> CGFloat {
		guard let model = dataSource[safe: indexPath.row] else { return .zero }
		let textHeight = ImageCollectionViewCell.calculateTagsLabelHeight(
			for: model,
			containerWidth: maxWidth
		)
		var imageSize = model.imageSize
		if imageSize.width > maxWidth {
			imageSize.height *= maxWidth / imageSize.width
		}
		return imageSize.height + textHeight
	}
}
