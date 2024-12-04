//
//  ImageCellViewModel.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//

import Foundation

class ImageCellViewModel {
    let imagePath: String
    let uploadStatus: String
    var progress: Float = 0.0 
    init(image: ImageModel) {
        self.imagePath = image.imagePath
        self.uploadStatus = image.uploadStatus
    }
}
