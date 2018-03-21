# HackerNewsAPIParsing
Different ways of parsing (raw JSON, swiftyJSON, Codable) and displaying data from hacker news

Aim: We want to build a data layer to connect to the Hacker News Feed https://hn.algolia.com/api/v1/search_by_date?query=ios and then parse the data returned as JSON into objects, using an asynchronous call then display the data in a table view.

Writing an API function with a closure to return the data:
Create an API Manager 
Write a function name that will get all the news articles
Make sure the function has a closure (or an unnamed) function as a parameter, this will return the data when parsed

func getHackerNews(completion: @escaping ([HackerNews]) -> Void ) {


}

getHackerNews is the function name to access our API
completion is the name of the parameter for the closure function, you call this when you have finished your task
@escaping is used when you pass blocks on
() -> Void this is a closure signature, the closure here has one parameter an array of [HackerNews] objects and returns nothing

Importing Libraries with Cocoapods:
Initialise your directory with Cocoapods, CD to the directory in terminal and install Alamofire https://cocoapods.org/?q=alamofire there are many different 3rd party libraries (AFNetworking is another one https://cocoapods.org/?q=AFnetwor ) it is up to you to choose what you prefer or write your own custom one
Import Alamofire into your APIManager

To make an Alamofire Request:
Call the Alamofire request function
Fill in the parameters you need to fill in are: 
The URL 
Method type (.get) 
The encoding which should be JSONEncoding.default
You can ask alamofire to respond with different type of data:
responseData will return a Data object , useful for using Codable and SwiftyJSON 
responseJSON will return a JSON object that you then have to unwrap by looking at the JSON

Parsing the JSON using CODABLE (FOR IOS 11 Only)
There are many ways you can do this in IOS 11 you can parse data using the Codable protocol, to this:
You must ask for responseData from Alamofire
Your Model Objects must have properties that match the json keys, and it must implement codable:

import Foundation

struct HackerNews: Codable {
    var title: String
    var story_title: String
    var comment_text: String
}



Get the data from the response:

if let jsonData = response.data {
}

Create a JSON Decoder:

let decoder = JSONDecoder()



Inside of a do {} catch {}  block try to decode the data:

do {
     let hackerNews = try decoder.decode([HackerNews].self, from: jsonData) //1
     return completion(hackerNews) //2
} catch {
     print("Unexpected error: JSON parsing error")
}
Try to decode the jsonData to the type HackerNews object
Return the hackerNews array to the table view that called this…
The whole code sample is here:

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


Parsing JSON using Swifty JSON (for non IOS 11 apps)
If you want to support IOS 10 or less then you cannot use Codable as this is just for IOS 11, in which case the easiest way to parse the JSON is by using a library called Swifty JSON https://cocoapods.org/?q=Swiftyjson 


    //GET DATA WITH SWifty JSON
    func getHackerNewsSwifty(completion: @escaping ([HackerNewsSwiftyJSONModel]) -> Void ) {
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios", 
                          method: .get,
                          encoding: JSONEncoding.default).responseData { (response) in  //1
                            switch response.result {
                            case .success(let jsonData):
                                let json = JSON(jsonData) //2
                                var news = [HackerNewsSwiftyJSONModel]() //3
                                
                                if let hackerNews = json["hits"].array { //4
                                    for j in hackerNews {
                                        news.append(HackerNewsSwiftyJSONModel.fromJSON(j)) //5
                                    }
                                }
                                completion(news) //6
                            case .failure(let error):
                                print("error \(error)")
                            }
        }
    }


Alamofire must request the responseData object
You need to pass Swifty JSON the jsonData object 
Create an array to hold the hacker news objects
Swifty json is smart enough just to get whatever value is returned for “hits” key, we know it is an array so must optionally check that
Looping the array of items we pass each one to our SWIFT JSON function written in the new Model Class

Create a class as the model object, that imports SwiftyJSON and will take a parameter of type JSON:

import Foundation
import SwiftyJSON
class HackerNewsSwiftyJSONModel {
    var title: String = ""
    var storyTitle: String = ""
    var commentText: String = ""
    
    static func fromJSON(_ json: JSON) -> HackerNewsSwiftyJSONModel { //1
        let news = HackerNewsSwiftyJSONModel() //2
        news.title = json["title"].string ?? "" //3
        news.storyTitle = json["story_title"].string ?? ""
        news.commentText = json["comment_text"].string ?? ""
        return news //4
    }
}
Create a static function that takes a Swift JSON object as parameter (this will be one JSON dictionary)
Create a new object to hold the unwrapped dictionary
Get each value out for the key and store it, you need to know the type and using Swifty JSON cast it to .string for example
Pass back the object to your API Manager

Parsing the JSON by requesting a JSON object and then unwrapping the dictionaries and arrays…
This is the hardest way of unwrapping data, you need to look at the JSON and work out what data you need (the keys) and where the Dictionaries and Arrays are and then optionally unwrap them...you must request responseJSON  from alamofire

        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?query=ios",
            method: .get,
            encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.result { //0
                case .success(let jsonData):
    
                   if let jsonDict = jsonData as? NSDictionary { //1
                        if  let hits = jsonDict["hits"] as? NSArray { //2
                            var articlesTable: [HackerNews] = [] //3
                            for dict in hits { //4
                                if let dict = dict as? NSDictionary{ //5
                                   let title = dict["title"] as? String ??dict["story_title"] as? String ?? "" //6
                                   let comment = dict["comment_text"] as? String ?? "" //7
                                   let hackerNews = HackerNews(title: title,
                                                                story_title: "",
                                                                comment_text: comment) //8
                                    articlesTable.append(hackerNews) //9
                                }
                            }
                            completion(articlesTable)
                        }
                    }
                case .failure(let error):
                    print("error \(error)")
                }
        }


       0) The  response.result will be of JSON type
The top most data is a dictionary so we optionally cast this to NSDictionary
The news articles are contained within “hits” it is an NSArray
Create an array of HackerNews Objects to store the unwrapped articles
Loop through the array
Optionally unwrap each dictionary
Get the values in the Dictionary for the keys
Get the values in the Dictionary for the keys
Create an instance of HackerNews
Add it to the array
Return it in a completion block

Loading the data in the Table View:
Once you have acquired the data from the API call you need to reload the table view to display it!!

    var hackerNewsObjects: [HackerNews] = [] //1
    override func viewDidLoad() {
        super.viewDidLoad()
        var datamanager: APIManager = APIManager.init()  // 2 
        datamanager.getHackerNewsCodable { (hackerNewsObjects) in //3
            //at this poit you have the data returned from the network 
            //then load or reload the table
            self.hackerNewsObjects = hackerNewsObjects //3
            self.tableView.reloadData()   //4
        }
    }


Create  property to store returned news items
Create a reference to API manager (you can also used a singleton shared instance so you don’t have to do this everytime)
Call our data layer function, fill in the completion block…
Store the returned objects to our local property of our table view
Reload the table

Loading the table:

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = hackerNewsObjects[indexPath.row].title // 1
        // Configure the cell...

        return cell
    }


Get the right news item object out of our news items

Return right number of rows, set number of rows to number of objects in our news array:

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hackerNewsObjects.count
    }



