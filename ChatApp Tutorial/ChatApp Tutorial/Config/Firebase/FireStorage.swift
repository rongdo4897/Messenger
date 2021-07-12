//
//  FireStorage.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 14/06/2021.
//

import Foundation
import FirebaseStorage
import ProgressHUD

let storage = Storage.storage()

class FireStorage {
    static let share = FireStorage()
    private init () {}
}

extension FireStorage {
    func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        // Đường dẫn tới storage
        let storageRef = storage.reference(forURL: Constants.fireStorageReference).child(directory)
        // image data
        let imageData = image.jpegData(compressionQuality: 0.6)
        // upload
        var task: StorageUploadTask!
        task = storageRef.putData(imageData!, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Lỗi khi upload ảnh: ", error!.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        // Tiến trình upload
        task.observe(StorageTaskStatus.progress) { snapshot in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        // Kiểm tra xem đường dẫn ảnh tồn tại chưa
        if Document.share.fileExistsAtPath(path: imageFileName) {
            // Lấy nó trong local
            if let contentOfFile = UIImage(contentsOfFile: Document.share.fileInDocumentDirectory(fileName: imageFileName)) {
                completion(contentOfFile)
            } else {
                completion(UIImage(named: "ic_avatar"))
            }
            
        } else {
            // Tải ảnh xuống từ firebase storage
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let documentQueue = DispatchQueue(label: "imageDownloadQueue")
                documentQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        // Lưu vào local
                        FireStorage.share.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(UIImage(named: "ic_avatar"))
                        }
                    }
                }
            }
        }
    }
    
    func saveFileLocally(fileData: NSData, fileName: String) {
        let documentUrl = Document.share.getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: documentUrl, atomically: true)
    }
}
