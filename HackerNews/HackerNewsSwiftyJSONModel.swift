//
//  HackerNewsSwiftyJSONModel.swift
//  HackerNews
//
//  Created by Ben Smith on 21/03/2018.
//  Copyright © 2018 Ben Smith. All rights reserved.
//

import Foundation
import SwiftyJSON
class HackerNewsSwiftyJSONModel {
    var title: String = ""
    var storyTitle: String = ""
    var commentText: String = ""
    
    static func fromJSON(_ json: JSON) -> HackerNewsSwiftyJSONModel {
        let news = HackerNewsSwiftyJSONModel()
        news.title = json["title"].string ?? ""
        news.storyTitle = json["story_title"].string ?? ""
        news.commentText = json["comment_text"].string ?? ""
        return news
    }
}


