//
//  DownloadService.swift
//  MADownload
//
//  Created by Vishwavijet on 09/12/18.
//  Copyright © 2018 Tarento. All rights reserved.
//

import Foundation

class DownloadService {
    
    var downloadsSession: URLSession!
    var activeDownloads: [String: DownloadTask] = [:]
    
    func startDownload(_ track: DownloadModel) {
        let download = DownloadTask(model: track)
        download.task = downloadsSession.downloadTask(with: URL.init(string: track.downloadURL)!)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[download.model.downloadURL] = download
    }
    
}
