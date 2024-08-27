import SDWebImage
import UIKit

extension UIImageView {
	func setImage(with url: URL, onComplete: @escaping ResultHandler<UIImage> = { _ in }) {
		setImage(with: url.absoluteString, onComplete: onComplete)
	}

	func setImage(with url: String, onComplete: @escaping ResultHandler<UIImage> = { _ in }) {
		sd_setImage(with: URL(string: url), completed: { img, error, _, _ in
			if let img {
				onComplete(.success(img))
			} else {
				onComplete(.failure(error ?? NSError.undefined))
			}
		})
	}
}
