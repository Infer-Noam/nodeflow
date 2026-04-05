//
//  DetailView.swift
//  nodeflow
//

import SwiftUI

struct DetailView: View {
    let item: Item

    var body: some View {
        VStack {
            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                .font(.title2)
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
