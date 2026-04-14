//
//  BookRow.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//

import SwiftUI
import Kingfisher

struct BookRow: View {

    let book: Book

    var body: some View {
        HStack(spacing: 12) {

            KFImage(URL(string: book.coverUrl))
                .standardStyle(width: 60, height: 80, cornerRadius: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                
                Text(book.author)
                    .font(.subheadline)
                
                Text(book.publisher)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical,4)
    }
}

#Preview {
    BookRow(book: MockBooks.list.first.unsafelyUnwrapped)
}
