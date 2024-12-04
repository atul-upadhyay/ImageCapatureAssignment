//
//  ImageModel.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//


import Foundation
import RealmSwift

class ImageModel: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var imagePath: String
    @Persisted var uploadStatus: String = "Pending"
    @Persisted var progress: Float = 0.0
    @Persisted var isUploaded: Bool = false 
}
