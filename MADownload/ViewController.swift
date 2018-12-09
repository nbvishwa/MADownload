//
//  ViewController.swift
//  MADownload
//
//  Created by Vishwavijet on 09/12/18.
//  Copyright © 2018 Tarento. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    var urls: [DownloadModel] = []
    let downloadService = DownloadService()
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.vishwavijet.MADownload")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadService.downloadsSession = downloadsSession
        self.infoLabel.isHidden = self.urls.count > 0 ? true : false
        self.tableView.isHidden = self.urls.count == 0 ? true : false
    }
    
    //MARK: Actions
    @IBAction func askForUrl(_ sender: Any) {
        let fileURLAlert = UIAlertController.init(title: "Enter URL", message: "Please enter the desired file link to start download.", preferredStyle: UIAlertControllerStyle.alert)
        
        let startAction = UIAlertAction.init(title: "Start", style: UIAlertActionStyle.default, handler: { (okAction) in
            guard let url = fileURLAlert.textFields?[0].text
                else { return }
            print(url)
            
            DispatchQueue.main.async {
                let downloadModel = DownloadModel.init(downloadURL: url, index: self.urls.count == 0 ? 0 : self.urls.count)
                if !self.urls.contains(where: { $0.downloadURL == downloadModel.downloadURL}){
                    
                    self.urls.append(DownloadModel.init(downloadURL: url, index: self.urls.count == 0 ? 0 : self.urls.count))
                    self.infoLabel.isHidden = self.urls.count > 0 ? true : false
                    self.tableView.isHidden = self.urls.count == 0 ? true : false
                    self.tableView.reloadData()
                }else {
                    print("url exists")
                }
                
            }
        })
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        fileURLAlert.addTextField { (urlField) in
            urlField.placeholder = "Your link here…"
            urlField.keyboardType = UIKeyboardType.URL
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: urlField, queue: OperationQueue.main) { (notification) in
                startAction.isEnabled = urlField.text!.count > 0 && self.validateUrl(urlString: urlField.text! as NSString)
            }
        }
        
        startAction.isEnabled = false
        fileURLAlert.addAction(startAction)
        fileURLAlert.addAction(cancelAction)
        self.present(fileURLAlert, animated: true, completion: nil)
    }
    
    //MARK: Custom
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func validateUrl (urlString: NSString) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
    

    
}

// MARK: - UITableView

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DownloadCell = tableView.dequeueReusableCell(withIdentifier: "downloadCell") as! DownloadCell
        
        let downloadModel = urls[indexPath.row]
        let downloadTask = downloadService.activeDownloads[downloadModel.downloadURL]
        cell.makeCell(for: downloadModel, isDownloaded: downloadModel.downloaded, downloadTask: downloadTask)
        
        if !downloadModel.downloaded && downloadTask == nil {
            downloadService.startDownload(downloadModel)
            self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        return cell
    }
}


extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let sourceURL = downloadTask.originalRequest?.url
            else {
            return
        }
        let downloadTask = downloadService.activeDownloads[sourceURL.absoluteString]
        downloadService.activeDownloads[sourceURL.absoluteString] = nil
        
        let destinationURL = localFilePath(for: sourceURL)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            downloadTask?.model.downloaded = true
        } catch let error {
            print("Failed to copy with error\(error.localizedDescription)")
        }
        
        if let index = downloadTask?.model.index {
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        guard let url = downloadTask.originalRequest?.url,
            let downloadTask = downloadService.activeDownloads[url.absoluteString]  else { return }

        downloadTask.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        
        print(String(format: "%.1f%% of %@", downloadTask.progress * 100, totalSize))

        DispatchQueue.main.async {
            if let downloadCell = self.tableView.cellForRow(at: IndexPath(row: downloadTask.model.index,
                                                                       section: 0)) as? DownloadCell {
                downloadCell.updateDisplay(progress: downloadTask.progress, totalSize: totalSize)
            }
        }
    }
    
}
