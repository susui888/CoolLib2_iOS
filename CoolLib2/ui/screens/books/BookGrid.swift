//
//  BookGrid.swift
//  CoolLib2
//
//  Created by Ryan Su on 2026/3/19.
//

import SwiftUI
import Kingfisher

struct BookGrid: View {
    
    let book: Book
    
    var body: some View {
        
        VStack(spacing: 4){
            
            KFImage(URL(string: book.coverUrl))
                .standardStyle(width: 170, height: 210)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(book.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(book.author) (\(book.publisher))")
                    .font(.caption2)
                    .lineLimit(1)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            
        }
        .frame(width: 160)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}

#Preview {
    BookGrid(book: MockBooks.list.first.unsafelyUnwrapped)
}
