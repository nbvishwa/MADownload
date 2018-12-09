//
//  DownloadCell.swift
//  MADownload
//
//  Created by Vishwavijet on 09/12/18.
//  Copyright © 2018 Tarento. All rights reserved.
//

import UIKit

class DownloadCell: UITableViewCell {
    
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    func makeCell(for model: DownloadModel, isDownloaded: Bool, downloadTask: DownloadTask?) {
        linkLabel.text = model.downloadURL
        progressView.isHidden = isDownloaded
        progressLabel.text = isDownloaded ? "Downloaded" : "Downloading…"
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
        progressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }
    
}

