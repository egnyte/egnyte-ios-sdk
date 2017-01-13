//
//  EgnyteSearchDataSource.swift
//  SampleApp
//
//  Created by Adam Kędzia on 01.12.2016.
//  Copyright © 2017 Egnyte. All rights reserved.
//

import UIKit
import EgnyteSDK

class EgnyteSearchDataSource: NSObject, EgnyteDataSource {
    var data = [EgnyteItem]()
    var cellConfiguration: ((EgnytePickerTableViewCell, EgnyteItem) -> EgnytePickerTableViewCell)?
    let egnyteApiClient: EgnyteAPIClient
    var query: String?
    weak var currentSearchRequest: Cancellable?
    
    init(apiClient: EgnyteAPIClient) {
        self.egnyteApiClient = apiClient
        super.init()
    }
    
    func fetchData(completion:@escaping (() throws -> [EgnyteItem]) -> Void) {
        currentSearchRequest?.cancel()
        
        guard let searchQuery = self.query else {
            completion({[]})
            return
        }
        
        let searchRequest = SearchRequest.init(apiClient: self.egnyteApiClient,
                                               query: searchQuery) { result in
                                                do {
                                                    let searchResult = try result()
                                                    self.data = searchResult.results as! [EgnyteSearchedFile]
                                                    completion({self.data})
                                                } catch let error {
                                                    guard (error as NSError).code != -999 else {
                                                        return
                                                    }
                                                    completion({throw error})
                                                }
        }
        
        currentSearchRequest = searchRequest
        searchRequest.enqueue()
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
