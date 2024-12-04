//
//  ImageCell.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    func configure(with viewModel: ImageCellViewModel) {
         if let data = try? Data(contentsOf: URL(fileURLWithPath: viewModel.imagePath)) {
             imageView.image = UIImage(data: data)
         }
         progressBar.progress = viewModel.progress
         statusLabel.text = viewModel.uploadStatus
     }
}
