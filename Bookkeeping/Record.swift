//
//  Record.swift
//  Bookkeeping
//
//  Created by lw on 2025/11/11.
//

import Foundation

struct Record: Identifiable {
    let id: UUID
    let amount: Double
    let category: String
    let createdAt: Date
    let note: String

    init(id: UUID = UUID(), amount: Double, category: String, createdAt: Date, note: String) {
        self.id = id
        self.amount = amount
        self.category = category
        self.createdAt = createdAt
        self.note = note
    }
}
