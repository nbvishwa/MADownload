//
//  DownloadModel.swift
//  MADownload
//
//  Created by Vishwavijet on 09/12/18.
//  Copyright © 2018 Tarento. All rights reserved.
//

import Foundation.NSURL

class DownloadModel {
    
    let downloadURL: String
    let index: Int
    var downloaded = false
    
    init(downloadURL: String, index: Int) {
        self.downloadURL = downloadURL
        self.index = index
    }
    
}
