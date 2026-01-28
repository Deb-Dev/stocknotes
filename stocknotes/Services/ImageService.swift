//
//  ImageService.swift
//  stocknotes
//
//  Created by Debasish Chowdhury on 2026-01-27.
//

import Foundation
import UIKit

class ImageService {
    static let shared = ImageService()
    
    private init() {}
    
    // Compress image data
    func compressImage(_ imageData: Data, maxSizeKB: Int = 500) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        var compression: CGFloat = 1.0
        var imageData = image.jpegData(compressionQuality: compression)
        
        // Reduce quality until under max size
        while let data = imageData, data.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
    
    // Resize image to max dimension
    func resizeImage(_ imageData: Data, maxDimension: CGFloat = 1200) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        
        guard ratio < 1.0 else {
            // Image is already smaller, just compress
            return compressImage(imageData)
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        return resizedImage.jpegData(compressionQuality: 0.8)
    }
    
    // Process image: resize and compress
    func processImage(_ imageData: Data) -> Data? {
        return resizeImage(imageData, maxDimension: 1200)
    }
}
