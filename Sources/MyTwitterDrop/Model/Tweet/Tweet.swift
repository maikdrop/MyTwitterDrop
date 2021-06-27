/*
 MIT License

Copyright (c) 2021 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 Tweet struct represents a tweet from Twitter who can be parsed directly from a tweet request. -> based on source: Stanford - Developing iOS 10 Apps with Swift - 9. Table View: https://www.youtube.com/watch?v=78LWmmDxr4k
 */

import Foundation

public struct Tweet : CustomStringConvertible, Codable {
    
    // MARK: - Properties
    public let text: String
    public let user: User
    public let created: Date
    public let identifier: String
    public let hashtags: [Hashtag]?
    public let urls: [Url]?
    public let userMentions: [UserMentions]?
    public let retweet: Retweet?
    
    public var description: String {
        "\(user) - \(created)\n\(text)\nhashtags: \(String(describing: hashtags))\nurls: \(String(describing: urls))\nuser_mentions: \(String(describing: userMentions))\nid: \(identifier)"
    }
    
    private var twitterDateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return formatter
    }()
    
    // MARK: - Create a tweet
    public init(text: String, user: User, created: Date, identifier: String) {
        self.text = text
        self.user = user
        self.created = created
        self.identifier = identifier
        self.hashtags = nil
        self.urls = nil
        self.userMentions = nil
        self.retweet = nil
    }
    
    public init?(json: Data) {
        
        if let newValue = try? JSONDecoder().decode(Tweet.self, from: json) {
            
            self = newValue
            
        } else {
            
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        user = try container.decode(User.self, forKey: .user)
        identifier = try container.decode(String.self, forKey: .identifier)
        
        let dateString = try container.decode(String.self, forKey: .created)
        
        if let date = twitterDateFormatter.date(from: dateString) {
            
            created = date
            
        } else {
            
            throw DecodingError.dataCorruptedError(
                forKey: .created, in: container, debugDescription: "Date string does not match the expected format of the formatter.")
        }
        
        retweet = try? container.decode(Retweet.self, forKey: .retweet)
        
        let entities = try container.nestedContainer(keyedBy: EntitiesCodingKeys.self, forKey: .entities)
        
        hashtags = try entities.decode([Hashtag].self, forKey: .hashtags)
        urls = try entities.decode([Url].self, forKey: .urls)
        userMentions = try entities.decode([UserMentions].self, forKey: .userMentions)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(user, forKey: .user)
        try container.encode(created, forKey: .created)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(retweet, forKey: .retweet)
        
        var entities = container.nestedContainer(keyedBy: EntitiesCodingKeys.self, forKey: .entities)
        try entities.encode(hashtags, forKey: .hashtags)
        try entities.encode(urls, forKey: .urls)
        try entities.encode(userMentions, forKey: .userMentions)
    }
}

// MARK: - Tweet coding keys
private extension Tweet {
    
    enum CodingKeys: String, CodingKey {
        case user
        case text = "full_text"
        case created = "created_at"
        case identifier = "id_str"
        case entities
        case retweet = "retweeted_status"
    }
    
    enum EntitiesCodingKeys: String, CodingKey {
        case hashtags
        case urls
        case userMentions = "user_mentions"
    }
}
