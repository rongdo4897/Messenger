//
//  Document.swift
//  ChatApp Tutorial
//
//  Created by Hoang Lam on 15/06/2021.
//

import Foundation

class Document {
    static let share = Document()
    private init() {}
}

extension Document {
    // Lấy đường dẫn đến tài liệu
    func getDocumentsURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    // Đường dẫn đến tệp thư mục tài liệu
    func fileInDocumentDirectory(fileName: String) -> String {
        return getDocumentsURL().appendingPathComponent(fileName).path
    }
    
    // Kiểm tra xem tồn tại tệp đường dẫn chưa
    func fileExistsAtPath(path: String) -> Bool {
        let filePath = fileInDocumentDirectory(fileName: path)
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: filePath)
    }
}
