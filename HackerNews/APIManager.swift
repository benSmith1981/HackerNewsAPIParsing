//
//  APIManager.swift
//  HackerNews
//
//  Created by Ben Smith on 20/03/2018.
//  Copyright © 2018 Ben Smith. All rights reserved.
//

import Foundation
//5 - Import Alamofire after installing the POD
import Alamofire
 import SwiftyJSON
//1 - Create an API Manager
class APIManager {
    
    //GET DATA WITH SWifty JSON
    func getHackerNewsSwifty(completion: @escaping ([HackerNewsSwiftyJSONModel]) -> Void ) {
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios",
                          method: .get,
                          encoding: JSONEncoding.default).responseData { (response) in
                            switch response.result {
                            case .success(let jsonData):
                                let json = JSON(jsonData)
                                var news = [HackerNewsSwiftyJSONModel]()
                                
                                if let hackerNews = json["hits"].array {
                                    for j in hackerNews {
                                        news.append(HackerNewsSwiftyJSONModel.fromJSON(j))
                                    }
                                }
                                completion(news)
                            case .failure(let error):
                                print("error \(error)")
                            }
        }
    }
    
    //2 - Write a function name that will get all the news articles
    //3 - Make sure the function has a closure (or an unnamed) function as a parameter, this will return the data when parsed
    func getHackerNewsCodable(completion: @escaping ([HackerNews]) -> Void ) {
//        getHackerNews is the function name to access our API
//        hackerNews is the name of the function, normal we call it completion or onComplete, you call this when you have finished your asynchronous task
//        @escaping is used when you pass blocks on
//        () -> Void this is a closure signature, the closure here has one parameter an array of [HackerNews] objects and returns nothing
        
        //GET DATA WITH CODABLE
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios",
                          method: .get,
                          encoding: JSONEncoding.default).responseData { (response) in
                            switch response.result {
                            case .success(let jsonData):
                                if let jsonData = response.data {
                                    let decoder = JSONDecoder()
                                    do {
                                        let hackerNews = try decoder.decode([HackerNews].self, from: jsonData)
                                        print(hackerNews)
                                        return completion(hackerNews)
                                    } catch {
                                        print("Unexpected error: JSON parsing error")
                                    }
                                }
                            case .failure(let error):
                                print("error \(error)")
                            }
        }
    
    }
    
    func getHackerNewsRawJSON(completion: @escaping ([HackerNews]) -> Void ) {
        //GET DATA WITH UNWRAPPING JSON OBJECTS FROM DICTIONARIES AND ARRAYS
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios",
                          method: .get,
                          encoding: JSONEncoding.default).responseJSON { (response) in
                            switch response.result {
                            case .success(let jsonData):
                                if let jsonDict = jsonData as? NSDictionary {
                                    if  let hits = jsonDict["hits"] as? NSArray {
                                        var articlesTable: [HackerNews] = []
                                        for dict in hits {
                                            if let dict = dict as? NSDictionary{
                                                let title = dict["title"] as? String ?? dict["story_title"] as? String ?? ""
                                                let comment = dict["comment_text"] as? String ?? ""
                                                let hackerNews = HackerNews(title: title,
                                                                            story_title: "",
                                                                            comment_text: comment)
                                                articlesTable.append(hackerNews)
                                            }
                                        }
                                        completion(articlesTable)
                                    }
                                    
                                }
                                
                            case .failure(let error):
                                print("error \(error)")
                            }
        }
    }
}
