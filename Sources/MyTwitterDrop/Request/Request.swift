/*
 MIT License

Copyright (c) 2021 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abtstract:
 This simple class for Twitter requests offers the ability to request a user home timeline and search for tweets. -> based on source: Stanford - Developing iOS 10 Apps with Swift - 9. Table View: https://www.youtube.com/watch?v=78LWmmDxr4k
 */

import Foundation
import OAuthSwift

public class Request: NSObject {
    
    // MARK: - Properties
    public private(set) var parameters: Dictionary<String, String> = [ParameterKey.tweetMode: ParameterKey.extended]
    public let requestType: RequestTypes
    
    public var min_id: String? = nil
    public var max_id: String? = nil
    
    private let oauthSwift: OAuth1Swift
    
    public var older: Request? {
        
        if min_id == nil, parameters[ParameterKey.maxID] != nil {
            
            return self
        }
        
        return max_id == nil ? nil : modifiedRequest(parametersToChange: [ParameterKey.maxID: max_id!])
    }
    
    public var newer: Request? {
       
        if max_id == nil, parameters[ParameterKey.sinceID] != nil {
            
            return self
        }
        
        return min_id == nil ? nil : modifiedRequest(parametersToChange: [ParameterKey.sinceID: min_id!])
    }
    
    // MARK: - Create a request for tweets
    private init(_ oauthSwift: OAuth1Swift, _ requestType: RequestTypes, _ parameters: Dictionary<String, String> = [:]) {
        self.oauthSwift = oauthSwift
        self.requestType = requestType
        self.parameters.merge(parameters) { (current, _) in current }
    }
    
    /**
     Creates a Twitter request for the home timeline of the authenticated user.
     
     - Parameter oauthSwift: The authentication object with user credentials for the request.
     - Parameter count: The tweets count.
     */
    public convenience init(oauthSwift: OAuth1Swift, count: Int = 0) {
        
        var parameters = [String:String]()
        
        if count > 0 { parameters[ParameterKey.count] = "\(count)" }
        
        self.init(oauthSwift, RequestTypes.homeTimeline, parameters)
    }
    
    /**
     Creates a Twitter request in order to search for tweets.
     
     - Parameter oauthSwift: The authentication object with user credentials for the request.
     - Parameter search: The search term that must be included in the text of the requested tweets.
     - Parameter resultType: Specifies the type of the search results.
     - Parameter count: The tweets count.
     */
    public convenience init(oauthSwift: OAuth1Swift, search: String, resultType: SearchResultType = .recent, count: Int = 0) {
        
        var parameters = [ParameterKey.query : search]
        
        if count > 0 { parameters[ParameterKey.count] = "\(count)" }
        
        parameters[ParameterKey.resultType] = resultType.rawValue
        
        self.init(oauthSwift, RequestTypes.searchForTweets, parameters)
    }
}

// MARK: - Tweet fetching
public extension Request {
    
    /**
     Fetches tweets from Twitter.
     
     - Parameter completion: Calls back with fetched tweets when the request is completed.
     
     Handler calls back with an empty array when the requested data is corrupt or an error occurs during request.
     */
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        
        _ = oauthSwift.client.get(requestUrl, parameters: self.parameters) { [weak self] result in
            
            switch result {
            case .success(let response):
                
                if let data = self?.getData(from: response), let tweets = try? JSONDecoder().decode([Tweet].self, from: data) {
                    
                    self?.synchronize {
                        
                        self?.captureFollowOnRequestInfo(tweets)
                    }
                    
                    completion(tweets)
                    
                } else {
                    completion([])
                }
            case .failure(let error):
                
                print(error.localizedDescription)
                
                completion([])
            }
        }
    }
}

// MARK: - Private utility functions
private extension Request {
    
    /**
     Returns a new tweet request.
     
     - Parameter parametersToChange: The new parameters for the request.
     - Parameter clearCount: Determines if the tweet count for the request is set or not.
     
     - Returns: A new tweet request with modified parameters.
     */
    private func modifiedRequest(parametersToChange: Dictionary<String, String>, clearCount: Bool = false) -> Request {
        
        var newParameters = parameters
        
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        
        if clearCount { newParameters[ParameterKey.count] = nil }
        
        return Request(oauthSwift, requestType, newParameters)
    }
    
    /**
     Captures min and max id.
     
     - Parameter tweets: The tweets of which min and max id are captured.
     */
    private func captureFollowOnRequestInfo(_ tweets: [Tweet]) {
        
        let sortedIds = tweets.map({ $0.identifier }).sortedNumerically(ascending: false)
        
        if let first = sortedIds.first {
            
            self.min_id = first
        }
        
        if let last = sortedIds.last, let lastIdAsInt = Int(last) {
            
            self.max_id = String(lastIdAsInt - 1)
        }
    }
    
    /**
     Synchronizing the current request.
     
     - Parameter closure: Calls back after synchronizing begins.
     */
    private func synchronize(_ closure: () -> Void) {
        
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    /**
     Returns the data of a Twitter response.
     
     - Parameter response: The response of a Twitter request.
     
     - Returns: The data of the response from a Twitter request.
     */
    private func getData(from response: OAuthSwiftResponse) -> Data? {
    
        switch requestType {
        case .searchForTweets:
            // if you search for tweets, a dictionary is returned with one key value pair: "statuses" as key and an an array of the searched tweets as the value.
            if let object = try? response.jsonObject() as? [String: Any], let tweets = object[Request.ParameterKey.statuses] {
                
                return try? JSONSerialization.data(withJSONObject: tweets, options: [])
            }
        case .homeTimeline:
            return response.data
        default:
            return nil
        }
        
        return nil
    }
}

extension Request {
    
    public enum SearchResultType: String {
        
        case mixed
        case recent
        case popular
    }
    
    public enum RequestTypes: String {
        
        case searchForTweets = "search/tweets"
        case homeTimeline = "statuses/home_timeline"
        case showUser = "users/show"
    }
}

// MARK: - Constants
private extension Request {
    
    private var requestUrl: String { ApiConstants.twitterURLPrefix + self.requestType.rawValue + ApiConstants.JSONExtension }
    
    private struct ParameterKey {
        
        static let count = "count"
        static let query = "q"
        static let userId = "user_id"
        static let statuses = "statuses"
        static let resultType = "result_type"
        static let resultTypeRecent = "recent"
        static let resultTypePopular = "popular"
        static let geocode = "geocode"
        static let maxID = "max_id"
        static let sinceID = "since_id"
        static let tweetMode = "tweet_mode"
        static let extended = "extended"
    }
    
     private struct ApiConstants {
        
        static let JSONExtension = ".json"
        static let twitterURLPrefix = "https://api.twitter.com/1.1/"
    }
}
