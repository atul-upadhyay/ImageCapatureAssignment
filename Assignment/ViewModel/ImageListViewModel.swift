//
//  ImageListViewModel.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//


import Foundation
import RealmSwift

class ImageListViewModel {
    private let realm = try! Realm()
    var images: Results<ImageModel>!

    init() {
        loadImages()
    }

    func loadImages() {
        images = realm.objects(ImageModel.self)
    }

    func uploadImage(at index: Int, progressHandler: @escaping (Float) -> Void, completion: @escaping (Error?) -> Void) {
        guard index < images.count else { return }
        let image = images[index]
        UploadManager.shared.upload(image: image, progressHandler: progressHandler, completion: completion)
    }

    func numberOfImages() -> Int {
        return images?.count ?? 0
    }
}
