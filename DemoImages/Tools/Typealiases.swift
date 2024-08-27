import Foundation

typealias Handler<T> = (T) -> Void
typealias ResultHandler<T> = (Result<T, Error>) -> Void
typealias Action = () -> Void
