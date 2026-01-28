//
//  ImageAttachmentView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI

struct ImageAttachmentView: View {
    let images: [Data]
    let onDelete: ((Int) -> Void)?
    
    init(images: [Data], onDelete: ((Int) -> Void)? = nil) {
        self.images = images
        self.onDelete = onDelete
    }
    
    var body: some View {
        if !images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, imageData in
                        if let uiImage = UIImage(data: imageData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                if let onDelete = onDelete {
                                    Button(action: {
                                        onDelete(index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    let sampleImage = UIImage(systemName: "photo")!
    let imageData = sampleImage.jpegData(compressionQuality: 0.8)!
    
    return ImageAttachmentView(
        images: [imageData, imageData],
        onDelete: { index in
            print("Delete image at index: \(index)")
        }
    )
}
