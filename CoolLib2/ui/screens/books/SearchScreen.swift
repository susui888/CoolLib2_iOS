//
//  SearchScreen.swift
//  CoolLib2
//
//  Created by susui on 2026/3/20.
//

import SwiftUI

struct SearchScreen:View {
    
    var body: some View {
        SearchScreenContent()
    }
}

struct SearchScreenContent: View {

    @EnvironmentObject var router: AppRouter
    
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
        HStack {
            Image(systemName: "clock")

            Text(item)

            Spacer()

            Button {
                remove(item)
            } label: {
                Image(systemName: "xmark")
            }
        }
        .contentShape(Rectangle())
    }

    func search(_ query: String) {
        guard !query.isEmpty else { return }

        SearchHistoryStore.add(query)
        history = SearchHistoryStore.load()
        
        text.removeAll()

        router.push(.books(searchTerm: query))
    }
    
    func delete(at offset: IndexSet){
        for index in offset{
            SearchHistoryStore.remove(history[index])
        }
        
        history = SearchHistoryStore.load()
    }
}

#Preview("Search") {
    let container = AppContainer()
    let router = AppRouter(container: container)
    
    NavigationStack {
        SearchScreenContent()
            .environmentObject(router)
    }
}
