//
//  UploadManager.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//


import Foundation
import RealmSwift

class UploadManager: NSObject, URLSessionTaskDelegate {
    static let shared = UploadManager()
    private let realm = try! Realm()

    private var progressHandlers: [String: (Float) -> Void] = [:]

    func upload(image: ImageModel, progressHandler: @escaping (Float) -> Void, completion: @escaping (Error?) -> Void) {
        guard !image.isUploaded else { return }

        try? realm.write {
            image.uploadStatus = "Uploading"
        }

        let url = URL(string: "https://www.clippr.ai/api/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let fileData = try? Data(contentsOf: URL(fileURLWithPath: image.imagePath))
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(image.id).jpg\"\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(fileData ?? Data())
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let task = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                try? self.realm.write {
                    image.uploadStatus = "Pending"
                }
                completion(error)
            } else {
                try? self.realm.write {
                    image.uploadStatus = "Completed"
                    image.isUploaded = true
                }
                NotificationManager.shared.sendNotification(title: "Upload Completed", body: "image has been uploaded.")
                completion(nil)
            }
        }

        progressHandlers[task.taskIdentifier.description] = progressHandler

        task.resume()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        if let handler = progressHandlers[task.taskIdentifier.description] {
            handler(progress)
        }
    }
}
