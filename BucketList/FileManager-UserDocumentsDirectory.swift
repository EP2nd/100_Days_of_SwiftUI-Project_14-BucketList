//
//  FileManager-UserDocumentsDirectory.swift
//  BucketList
//
//  Created by Edwin Przeźwiecki Jr. on 07/02/2023.
//

import Foundation

extension FileManager {
//    func getDocumentsDirectory() -> URL {
    static var documentsDirectory: URL {
        self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
