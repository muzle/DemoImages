import Foundation

struct HitsDTO: Codable {
	let total, totalHits: Int
	let hits: [HitDTO]
}
