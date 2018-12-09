//
//  DownloadTask.swift
//  MADownload
//
//  Created by Vishwavijet on 09/12/18.
//  Copyright © 2018 Tarento. All rights reserved.
//

import Foundation

class DownloadTask {
    
    var model: DownloadModel
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var progress: Float = 0
    
    init(model: DownloadModel) {
        self.model = model
    }
}
