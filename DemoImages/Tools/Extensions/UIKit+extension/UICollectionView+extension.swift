import UIKit

extension UICollectionView {
	func register<T: UICollectionViewCell>(_ type: T.Type) {
		register(type.self, forCellWithReuseIdentifier: String(describing: type))
	}

	func dequeue<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
		guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as? T else {
			preconditionFailure("Error get cell")
		}
		return cell
	}
}
