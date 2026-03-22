//
//  SearchScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import SwiftUI

struct SearchScreen:View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        SearchScreenContent(
            onSearchTap: { query in
                router.push(.books(searchTerm: query))
            }
        )
    }
}

struct SearchScreenContent: View {
    let onSearchTap: (String) -> Void
    
    @State private var text = ""
    @State private var history: [String] = []

    var body: some View {
        List {
            if !history.isEmpty {
                Section("Recent Searches") {
                    ForEach(history, id: \.self) { item in
                        historyRow(item)
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $text, prompt: "Search book or auther")
        .onSubmit(of: .search) {
            search(text)
        }
        .onAppear(){
            history = SearchHistoryStore.load()
        }
        .toolbar{
            if !history.isEmpty{
                Button("Clear"){
                    SearchHistoryStore.clear()
                    history.removeAll()
                }
            }
        }
    }

    func historyRow(_ item: String) -> some View {
        Button {
            search(item)
        } label: {
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(item)
                    .foregroundStyle(.primary)
                Spacer()
                
                Image(systemName: "arrow.up.left")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    func search(_ query: String) {
        guard !query.isEmpty else { return }

        SearchHistoryStore.add(query)
        history = SearchHistoryStore.load()
        
        text.removeAll()

        onSearchTap(query)
    }
    
    func delete(at offset: IndexSet){
        for index in offset{
            SearchHistoryStore.remove(history[index])
        }
        
        history = SearchHistoryStore.load()
    }
}

#Preview("Search") {
   
    NavigationStack {
        SearchScreenContent(
            onSearchTap: { _ in }
        )
    }
}
