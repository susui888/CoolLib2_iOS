//
//  BookRow.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//

import SwiftUI

struct BookRow: View {

    let book: Book

    var body: some View {
        HStack(spacing: 12) {

            AsyncImage(url: URL(string: book.coverUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray.opacity(0.2))
            }
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

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
