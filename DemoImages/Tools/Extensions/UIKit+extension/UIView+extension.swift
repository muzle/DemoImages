import UIKit

extension UIView {
	func addSubviews(_ views: UIView...) {
		views.forEach(addSubview(_:))
	}

	func pin(to view: UIView) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: view.topAnchor),
			leadingAnchor.constraint(equalTo: view.leadingAnchor),
			trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}

	func pin(to guide: UILayoutGuide) {
		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: guide.topAnchor),
			leadingAnchor.constraint(equalTo: guide.leadingAnchor),
			trailingAnchor.constraint(equalTo: guide.trailingAnchor),
			bottomAnchor.constraint(equalTo: guide.bottomAnchor)
		])
	}

	func pinCenter(to guide: UILayoutGuide) {
		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			centerXAnchor.constraint(equalTo: guide.centerXAnchor),
			centerYAnchor.constraint(equalTo: guide.centerYAnchor)
		])
	}
}
