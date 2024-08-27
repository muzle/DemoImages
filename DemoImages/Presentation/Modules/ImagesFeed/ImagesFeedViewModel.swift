import Combine
import Foundation

enum ImagesFeedViewState {
	case idle
	case loading
	case error(ErrorView.Model)
	case dataSource([ImageCollectionViewCell.Model])
}

final class ImagesFeedViewModel {
	// MARK: - Properites

	var state: AnyPublisher<ImagesFeedViewState, Never> {
		stateSubject.eraseToAnyPublisher()
	}

	// MARK: - Init

	init(imagesReportiory: ImagesRepository, router: ImagesFeedRouter) {
		self.imagesReportiory = imagesReportiory
		self.router = router
		bind()
	}

	// MARK: - Methods

	func onTextChanged(text: String) {
		querySubject.send(text)
	}

	func onItemSelected(indexPath: IndexPath) {
		let indices = indexPath.row % 2 == 0
		? [indexPath.row, indexPath.row + 1]
		: [indexPath.row, indexPath.row - 1]
		let images = indices.compactMap { self.images[$0] }
		router.openFullImage(images: images)
	}

	// MARK: - Private properties

	private let imagesReportiory: ImagesRepository
	private let router: ImagesFeedRouter
	private let stateSubject = CurrentValueSubject<ImagesFeedViewState, Never>(.idle)
	private let querySubject = CurrentValueSubject<String, Never>("")
	private let retrySubject = PassthroughSubject<Void, Never>()
	private var cancellables = Set<AnyCancellable>()
	private var images = [ImageInfo?]()
}

// MARK: - Private methods

private extension ImagesFeedViewModel {
	func bind() {
		let inputQuery = querySubject
			.removeDuplicates()
			.debounce(for: 0.5, scheduler: DispatchQueue.main)

		let retryQuery = retrySubject
			.map { [querySubject] in querySubject.value }

		Publishers.Merge(inputQuery, retryQuery)
			.handleEvents(receiveOutput: { [stateSubject] _ in stateSubject.send(.loading) })
			.map(updateState(query:))
			.switchToLatest()
			.sink(receiveValue: { [stateSubject] state in
				stateSubject.send(state)
			})
			.store(in: &cancellables)
	}

	func updateState(query: String) -> AnyPublisher<ImagesFeedViewState, Never> {
		fetchImages(query: query)
			.handleEvents(receiveOutput: { [weak self] in self?.images = $0 })
			.compactMap { [weak self] items -> ImagesFeedViewState? in
				guard let self else { return nil }
				let dataSource = items.map(makeCellModel(imageInfo:))
				return .dataSource(dataSource)
			}
			.catch { [retrySubject] _ -> AnyPublisher<ImagesFeedViewState, Never> in
				let model = ErrorView.Model.common { [retrySubject] in
					retrySubject.send(())
				}
				return Just(.error(model)).eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}

	/// По условию ТЗ если в левом на квери пришло 3 картинки, а на query+"graffiti" пришла 1, то нужно показывать ячейки только с лоадером
	/// поэтому ответ может быть опциональным
	func fetchImages(query: String) -> AnyPublisher<[ImageInfo?], Error> {
		if query.isEmpty { return .result(.success([])) }

		return Publishers.CombineLatest(
			imagesReportiory.fetch(query: query, count: 10),
			imagesReportiory.fetch(query: query + "graffiti", count: 10)
		).map { lhs, rhs in
			var images = [ImageInfo?]()
			for i in 0 ..< max(lhs.infos.count, rhs.infos.count) {
				images.append(lhs.infos[safe: i])
				images.append(rhs.infos[safe: i])
			}
			return images
		}
		.eraseToAnyPublisher()
	}

	func makeCellModel(imageInfo: ImageInfo?) -> ImageCollectionViewCell.Model {
		ImageCollectionViewCell.Model(
			imageURL: imageInfo?.preview.url,
			tags: (imageInfo?.tags.joined(separator: ", ")).orEmpty,
			imageSize: imageInfo?.preview.size ?? .zero
		)
	}
}
