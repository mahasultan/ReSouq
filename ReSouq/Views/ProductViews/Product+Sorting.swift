//
//  Product+Sorting.swift
//  ReSouq
//
//
extension Array where Element == Product {
    func sortedByAvailabilityThenDate() -> [Product] {
        self.sorted {
            let isSoldA = $0.isSold ?? false
            let isSoldB = $1.isSold ?? false

            if isSoldA != isSoldB {
                return !isSoldA && isSoldB // unsold before sold
            } else {
                return ($0.createdAt) > ($1.createdAt)
            }
        }
    }
}

