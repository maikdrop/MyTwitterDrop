/*
 MIT License

Copyright (c) 2021 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

// MARK: - Additional entities, which belong to a tweet.
public extension Tweet {
    
    struct UserMentions: CustomStringConvertible, Codable {
    
        // MARK: - Properties
        public let name: String
        public let screenName: String
        public let identifier: String
        public let indices: [Int]
        
        public var description: String { return "Name: \(name), " + "Screen Name: \(screenName), " + "id: \(identifier), " + "Indices: \(indices)" }
        
        // MARK: - Create a user mention
        public init(name: String, screenName: String, identifier: String, indices: [Int]) {
            self.name = name
            self.screenName = screenName
            self.identifier = identifier
            self.indices = indices
        }
        
        // MARK: - User mention coding keys
        enum CodingKeys: String, CodingKey {
            
            case name
            case screenName = "screen_name"
            case identifier = "id_str"
            case indices
        }
    }
    
    struct Url: CustomStringConvertible, Codable {
        
        // MARK: - Properties
        public let url: String
        public let displayUrl: String
        public let expandedUrl: String
        public let indices: [Int]
        
        public var description: String { return "URL: \(url), " + "Display URL: \(displayUrl), " + "Expanded URL: \(expandedUrl), " + "Indices: \(indices)"}
        
        // MARK: - Create a URL
        public init(url: String, displayUrl: String, expandedUrl: String, indices: [Int]) {
            self.url = url
            self.displayUrl = displayUrl
            self.expandedUrl = expandedUrl
            self.indices = indices
        }
        
        // MARK: - URL coding keys
        enum CodingKeys: String, CodingKey {
            
            case url
            case displayUrl = "display_url"
            case expandedUrl = "expanded_url"
            case indices
        }
    }
    
    struct Hashtag: CustomStringConvertible, Codable {
        
        // MARK: - Properties
        public let indices: [Int]
        public let text: String
        
        public var description: String { return "Text: \(text), " + "Indices: \(indices)" }
        
        // MARK: - Create an Hashtag
        public init(indices: [Int], text: String) {
            self.indices = indices
            self.text = text
        }
    }
}
