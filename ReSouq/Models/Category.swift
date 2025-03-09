//
//  Category.swift
//  ReSouq
//
//


import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    let parentCategoryID: String?
}
