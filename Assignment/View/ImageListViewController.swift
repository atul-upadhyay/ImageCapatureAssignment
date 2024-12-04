//
//  ImageListViewController.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//


import UIKit
import RealmSwift
import AVFoundation

class ImageListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!

    private let viewModel = ImageListViewModel()
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupCamera()
        self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        
       
    }
    
    
    @IBAction func capturePhoto(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            guard indexPath.row < viewModel.images.count else { return cell }

            let image = viewModel.images[indexPath.row]
            let cellViewModel = ImageCellViewModel(image: image)
            cell.configure(with: cellViewModel)

            // Update progress dynamically
            viewModel.uploadImage(at: indexPath.row, progressHandler: { progress in
                DispatchQueue.main.async {
                    cell.progressBar.progress = progress
                    cell.statusLabel.text = progress == 1.0 ? "Completed" : "Uploading"
                }
            }, completion: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Upload failed: \(error.localizedDescription)")
                    } else {
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            })

            return cell
        }


}


extension ImageListViewController: AVCapturePhotoCaptureDelegate {
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("Camera not available. Simulators do not support camera hardware.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print("Failed to set up camera: \(error.localizedDescription)")
            return
        }

        photoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(photoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, below: collectionView.layer)

        captureSession.startRunning()
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error.localizedDescription)")
            return
        }

        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            saveImageToLocalDirectory(image: image)
        } else {
            // Simulate a capture with a placeholder image
            print("Using placeholder image on simulator.")
            if let placeholderImage = UIImage(systemName: "photo") {
                saveImageToLocalDirectory(image: placeholderImage)
            }
        }
    }


    func saveImageToLocalDirectory(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileName = UUID().uuidString + ".jpg"
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            try data.write(to: filePath)
            let newImage = ImageModel()
            newImage.imagePath = filePath.path
            let realm = try! Realm()
            try realm.write {
                realm.add(newImage)
            }
            collectionView.reloadData()
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }

    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
