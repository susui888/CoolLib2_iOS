//
//  ImageUpload.swift
//  Containerized Library Ecosystem
//
//  Created by Ryan Su on 2026/5/3.
//

import SwiftUI
import PhotosUI

/// A horizontal scroll row that displays a list of selected image attachments
struct ImageAttachmentRow: View {
    let images: [PhotosPickerItem]
    var onRemoveImage: (Int) -> Void

    var body: some View {
        if !images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<images.count, id: \.self) { index in
                        ImagePreviewItem(item: images[index]) {
                            // Callback to remove the image at the specific index
                            onRemoveImage(index)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

/// An individual preview item that asynchronously loads and displays a PhotosPicker thumbnail
struct ImagePreviewItem: View {
    let item: PhotosPickerItem
    var onRemove: () -> Void
    
    @State private var loadedImage: Image?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main Image Content
            Group {
                if let loadedImage {
                    loadedImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Placeholder shown while the image is loading from the library
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Delete button in the top-right corner
            Button(action: onRemove) {
                ZStack {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .background(
                            Color.black.opacity(0.5),
                            in: UnevenRoundedRectangle(bottomLeadingRadius: 8)
                        )
                }
            }
        }
        .task {
            // Asynchronously load image data from the user's photo library
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
        }
    }
}
