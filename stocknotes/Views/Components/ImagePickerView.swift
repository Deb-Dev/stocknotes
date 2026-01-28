//
//  ImagePickerView.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    let maxImages: Int
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxImages
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                if self.parent.selectedImages.count < self.parent.maxImages {
                                    self.parent.selectedImages.append(image)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ImagePickerButton: View {
    @Binding var selectedImages: [UIImage]
    let maxImages: Int
    let onImagesSelected: ([Data]) -> Void
    
    @State private var showingImagePicker = false
    @State private var tempImages: [UIImage] = []
    
    var body: some View {
        Button(action: {
            tempImages = selectedImages
            showingImagePicker = true
        }) {
            HStack {
                Image(systemName: "photo.on.rectangle")
                Text("Add Image\(maxImages > 1 ? "s" : "")")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
        }
        .disabled(selectedImages.count >= maxImages)
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImages: $tempImages, maxImages: maxImages)
                .onDisappear {
                    if !tempImages.isEmpty {
                        selectedImages = tempImages
                        processAndSaveImages()
                    }
                }
        }
    }
    
    private func processAndSaveImages() {
        let imageService = ImageService.shared
        var processedData: [Data] = []
        
        for image in selectedImages {
            if let imageData = image.jpegData(compressionQuality: 1.0),
               let processed = imageService.processImage(imageData) {
                processedData.append(processed)
            }
        }
        
        onImagesSelected(processedData)
    }
}

#Preview {
    ImagePickerButton(selectedImages: .constant([]), maxImages: 3) { _ in }
        .padding()
}
