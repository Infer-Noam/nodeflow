//
//  HomeViewModel.swift
//  nodeflow
//

import Foundation
import SwiftData

@Observable
class HomeViewModel {
    var items: [Item] = []

    func addItem(context: ModelContext) {
        let newItem = Item(timestamp: Date())
        context.insert(newItem)
    }

    func deleteItems(offsets: IndexSet, from items: [Item], context: ModelContext) {
        for index in offsets {
            context.delete(items[index])
        }
    }
}
