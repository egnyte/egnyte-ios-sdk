//
//  EgnytePickerDataSource.swift
//  SampleApp
//
//  Created by Adam Kędzia on 28.11.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

protocol EgnyteDataSource: UITableViewDataSource {
    func fetchData(completion:@escaping (() throws -> [EgnyteItem]) -> Void)
    var cellConfiguration: ((EgnytePickerTableViewCell, EgnyteItem) -> EgnytePickerTableViewCell)? {set get}
    var data: [EgnyteItem] {get}
}

class EgnytePickerDataSource: NSObject, EgnyteDataSource {
    var data = [EgnyteItem]()
    var cellConfiguration: ((EgnytePickerTableViewCell, EgnyteItem) -> EgnytePickerTableViewCell)?
    weak var egnyteApiClient: EgnyteAPIClient?
    let folder: EgnyteFolder
    
    init(apiClient: EgnyteAPIClient, folder: EgnyteFolder) {
        self.egnyteApiClient = apiClient
        self.folder = folder
        super.init()
    }
    
    func fetchData(completion:@escaping (() throws -> [EgnyteItem]) -> Void) {
        let folderContentRequestBuilder = ListFolderContentRequestBuilder.init(apiClient: self.egnyteApiClient!,
                                                                               path: self.folder.path) { result in
                                                                                do {
                                                                                    let folderContent = try result()
                                                                                    var fileAndFolder = [EgnyteItem]()
                                                                                    fileAndFolder.append(contentsOf: (folderContent.folders as [EgnyteItem]))
                                                                                    fileAndFolder.append(contentsOf: (folderContent.files as [EgnyteItem]))
                                                                                    self.data = fileAndFolder
                                                                                    completion({return fileAndFolder})
                                                                                }catch let error {
                                                                                    completion({throw error})
                                                                                }
        }
        
        folderContentRequestBuilder.includePermissions = true
        let folderContentRequest = folderContentRequestBuilder.buildListFileOrFolderRequest()
        
        folderContentRequest.enqueue()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kEgnytePickerTableViewCell", for: indexPath) as! EgnytePickerTableViewCell
        let result = self.cellConfiguration!(cell, self.data[indexPath.row])
        return result
    }
    
}
