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
    let note: String
}

struct ContentView: View {
    @State private var amountText = ""
    @State private var selectedCategory = "餐饮"
    @State private var records: [Record] = []
    @State private var showInputError = false
    @State private var noteText = ""
    @State private var selectedDate = Date()

    private let categories = ["餐饮", "交通", "购物", "娱乐", "其他"]
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "CNY"
        return formatter
    }()
    private var allowedDateRange: ClosedRange<Date> {
        let today = Date()
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: today) ?? today
        return tenDaysAgo...today
    }

    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 5) {
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Text("输入金额")
                                        .frame(width: 70, alignment: .leading)
                                    TextField("例如：45.50", text: $amountText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.roundedBorder)
                                }

                                if showInputError {
                                    Text("请输入有效金额")
                                        .font(.footnote)
                                        .foregroundStyle(.red)
                                }

                                HStack(spacing: 12) {
                                    Text("备注")
                                        .frame(width: 70, alignment: .leading)
                                    TextField("可选：例如 午餐", text: $noteText)
                                        .textFieldStyle(.roundedBorder)
                                }

                                HStack(spacing: 12) {
                                    Text("日期")
                                        .frame(width: 70, alignment: .leading)
                                    DatePicker("", selection: $selectedDate, in: allowedDateRange, displayedComponents: .date)
                                        .labelsHidden()
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        Section(header: Text("选择类型")) {
                            Picker("类型", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    Button(action: saveRecord) {
                        Label("保存记账", systemImage: "tray.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
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
                                    if !record.note.isEmpty {
                                        Text(record.note)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text(currencyFormatter.string(from: record.amount as NSNumber) ?? "\(record.amount)")
                                    .fontWeight(.semibold)
                            }
                        }
                        .listStyle(.insetGrouped)
                    }
                }
                .padding(.top, 0)
            }
            .tabItem {
                Label("记账", systemImage: "list.bullet.clipboard")
            }

            AnalysisView()
                .tabItem {
                    Label("分析", systemImage: "chart.pie")
                }
        }
    }

    private func saveRecord() {
        guard let amount = Double(amountText), amount > 0 else {
            showInputError = true
            return
        }
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newRecord = Record(amount: amount, category: selectedCategory, createdAt: selectedDate, note: trimmedNote)
        records.insert(newRecord, at: 0)
        amountText = ""
        noteText = ""
        selectedDate = Date()
        showInputError = false
    }
}

private struct AnalysisView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("分析页面开发中…")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
