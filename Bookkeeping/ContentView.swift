//
//  ContentView.swift
//  Bookkeeping
//
//  Created by lw on 2025/11/11.
//

import SwiftUI

private struct Record: Identifiable {
    let id = UUID()
    let amount: Double
    let category: String
    let createdAt: Date
}

struct ContentView: View {
    @State private var amountText = ""
    @State private var selectedCategory = "餐饮"
    @State private var records: [Record] = []
    @State private var showInputError = false

    private let categories = ["餐饮", "交通", "购物", "娱乐", "其他"]
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "CNY"
        return formatter
    }()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Form {
                    Section(header: Text("输入金额")) {
                        TextField("例如：45.50", text: $amountText)
                            .keyboardType(.decimalPad)
                        if showInputError {
                            Text("请输入有效金额")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }

                    Section(header: Text("选择类型")) {
                        Picker("类型", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Button(action: saveRecord) {
                        Label("保存记账", systemImage: "tray.and.arrow.down")
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                if records.isEmpty {
                    ContentUnavailableView("暂无记录", systemImage: "tray", description: Text("添加一笔记账开始统计你的支出。"))
                } else {
                    List(records) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.category)
                                    .font(.headline)
                                Text(record.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(currencyFormatter.string(from: record.amount as NSNumber) ?? "\(record.amount)")
                                .fontWeight(.semibold)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding(.top)
            .navigationTitle("简单记账")
        }
    }

    private func saveRecord() {
        guard let amount = Double(amountText), amount > 0 else {
            showInputError = true
            return
        }
        let newRecord = Record(amount: amount, category: selectedCategory, createdAt: Date())
        records.insert(newRecord, at: 0)
        amountText = ""
        showInputError = false
    }
}

#Preview {
    ContentView()
}
