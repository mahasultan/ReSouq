import Foundation

struct SearchQuery: Identifiable, Hashable {
    let id = UUID()
    let query: String
    let filters: FilterOptions
}
