//
//  BookkeepingTabView.swift
//  Bookkeeping
//
//  Created by lw on 2025/11/11.
//

import SwiftUI

struct BookkeepingTabView: View {
    @State private var amountText = ""
    @State private var selectedCategory = "餐饮"
    @State private var records: [Record] = []
    @State private var showInputError = false
    @State private var noteText = ""
    @State private var selectedDate = Date()
    @State private var editingRecordID: UUID?

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
        NavigationStack {
            VStack(spacing: 5) {
                formSection
                actionButtons
                recordsSection
            }
            .padding(.top, 0)
        }
    }

    private var formSection: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    labeledTextField(title: "输入金额",
                                     placeholder: "例如：45.50",
                                     text: $amountText,
                                     keyboard: .decimalPad)

                    if showInputError {
                        Text("请输入有效金额")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    labeledTextField(title: "备注",
                                     placeholder: "可选：例如 午餐",
                                     text: $noteText)

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
    }

    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button(action: saveRecord) {
                Label(editingRecordID == nil ? "保存记账" : "更新记录",
                      systemImage: editingRecordID == nil ? "tray.and.arrow.down" : "square.and.pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            if editingRecordID != nil {
                Button("取消编辑", role: .cancel, action: resetForm)
            }
        }
        .padding(.horizontal)
    }

    private var recordsSection: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView("暂无记录", systemImage: "tray", description: Text("添加一笔记账开始统计你的支出。"))
            } else {
                List {
                    ForEach(records) { record in
                        RecordRow(record: record, formatter: currencyFormatter)
                            .swipeActions(edge: .trailing) {
                                Button("删除", role: .destructive) {
                                    deleteRecord(record)
                                }
                                Button("编辑") {
                                    startEditing(record)
                                }
                                .tint(.blue)
                            }
                    }
                    .onDelete(perform: deleteRecords)
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func labeledTextField(title: String,
                                  placeholder: String,
                                  text: Binding<String>,
                                  keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(width: 70, alignment: .leading)
            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
    }

    private func saveRecord() {
        guard let amount = Double(amountText), amount > 0 else {
            showInputError = true
            return
        }
        let trimmedNote = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let recordDate = selectedDate

        if let editingID = editingRecordID,
           let index = records.firstIndex(where: { $0.id == editingID }) {
            records[index] = Record(id: editingID,
                                    amount: amount,
                                    category: selectedCategory,
                                    createdAt: recordDate,
                                    note: trimmedNote)
        } else {
            let newRecord = Record(amount: amount,
                                   category: selectedCategory,
                                   createdAt: recordDate,
                                   note: trimmedNote)
            records.insert(newRecord, at: 0)
        }

        resetForm()
    }

    private func startEditing(_ record: Record) {
        editingRecordID = record.id
        amountText = record.amount.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(record.amount))" : "\(record.amount)"
        selectedCategory = record.category
        noteText = record.note
        selectedDate = record.createdAt
        showInputError = false
    }

    private func deleteRecord(_ record: Record) {
        records.removeAll { $0.id == record.id }
        if editingRecordID == record.id {
            resetForm()
        }
    }

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            if records.indices.contains(index),
               records[index].id == editingRecordID {
                resetForm()
            }
        }
        records.remove(atOffsets: offsets)
    }

    private func resetForm() {
        amountText = ""
        noteText = ""
        selectedDate = Date()
        showInputError = false
        editingRecordID = nil
    }
}

private struct RecordRow: View {
    let record: Record
    let formatter: NumberFormatter

    var body: some View {
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
            Text(formatter.string(from: record.amount as NSNumber) ?? "\(record.amount)")
                .fontWeight(.semibold)
        }
    }
}
