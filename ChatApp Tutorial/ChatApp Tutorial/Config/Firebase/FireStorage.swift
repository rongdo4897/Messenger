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

//MARK: - image
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
                    // Lấy data từ đường dẫn tệp
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

//MARK: - video
extension FireStorage {
    func uploadVideo(_ videoData: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        // Đường dẫn tới storage
        let storageRef = storage.reference(forURL: Constants.fireStorageReference).child(directory)

        // upload
        var task: StorageUploadTask!
        task = storageRef.putData(videoData as Data, metadata: nil, completion: { metadata, error in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Lỗi khi upload video: ", error!.localizedDescription)
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
    
    func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        // Kiểm tra xem đường dẫn ảnh tồn tại chưa
        if Document.share.fileExistsAtPath(path: videoFileName) {
            // Lấy nó trong local
            completion(true, videoFileName)
            
        } else {
            // Tải xuống từ firebase storage
            let documentQueue = DispatchQueue(label: "videoDownloadQueue")
            documentQueue.async {
                // Lấy data từ đường dẫn tệp
                let data = NSData(contentsOf: videoUrl!)
                if data != nil {
                    // Lưu vào local
                    FireStorage.share.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                } else {
                    print("Không có tài liệu video trong firebase")
                }
            }
        }
    }
}

//MARK: - Audio
extension FireStorage {
    func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        let fileName = audioFileName + ".m4a"
        // Đường dẫn tới storage
        let storageRef = storage.reference(forURL: Constants.fireStorageReference).child(directory)

        // upload
        var task: StorageUploadTask!
        
        if Document.share.fileExistsAtPath(path: fileName) {
            if let audioData = NSData(contentsOfFile: Document.share.fileInDocumentDirectory(fileName: fileName)) {
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { metadata, error in
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("Lỗi khi upload audio: ", error!.localizedDescription)
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
            } else {
                print("Không thể upload audio")
            }
        }
    }
    
    func downloadAudio(audioLink: String, completion: @escaping (_ videoFileName: String) -> Void) {
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"
        // Kiểm tra xem đường dẫn ảnh tồn tại chưa
        if Document.share.fileExistsAtPath(path: audioFileName) {
            // Lấy nó trong local
            completion(audioFileName)
            
        } else {
            // Tải xuống từ firebase storage
            let documentQueue = DispatchQueue(label: "audioDownloadQueue")
            documentQueue.async {
                // Lấy data từ đường dẫn tệp
                let data = NSData(contentsOf: URL(string: audioLink)!)
                if data != nil {
                    // Lưu vào local
                    FireStorage.share.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                } else {
                    print("Không có tài liệu audio trong firebase")
                }
            }
        }
    }
}
