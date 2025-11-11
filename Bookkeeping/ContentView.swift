//
//  ContentView.swift
//  Bookkeeping
//
//  Created by lw on 2025/11/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BookkeepingTabView()
                .tabItem {
                    Label("记账", systemImage: "list.bullet.clipboard")
                }

            AnalysisView()
                .tabItem {
                    Label("分析", systemImage: "chart.pie")
                }
        }
    }
}

#Preview {
    ContentView()
}
