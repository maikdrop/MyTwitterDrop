/*
 MIT License

Copyright (c) 2021 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 User struct represents a Twitter User who can be parsed directly from a Twitter request. -> based on source: Stanford - Developing iOS 10 Apps with Swift - 9. Table View: https://www.youtube.com/watch?v=78LWmmDxr4k
 */

import Foundation

public struct User: CustomStringConvertible, Hashable, Codable {

    // MARK: - Properties
    public let screenName: String
    public let name: String
    public let identifier: String
    public let verified: Bool
    public let profileImageUrl: String
    
    public var description: String { "@\(screenName) (\(name))\(verified ? " ✅" : "")" }

    // MARK: - Create a user
    public init(screenName: String, name: String, id: String, verified: Bool, profileImageURL: String) {
        self.screenName = screenName
        self.name = name
        self.identifier = id
        self.verified = verified
        self.profileImageUrl = profileImageURL
    }
    
    public init?(json: Data) {
        
        if let newValue = try? JSONDecoder().decode(User.self, from: json) {
            
            self = newValue
            
        } else {
            
            return nil
        }
    }
}

// MARK: - User coding keys
private extension User {

    private enum CodingKeys: String, CodingKey {
        
        case name, verified
        case screenName = "screen_name"
        case identifier = "id_str"
        case profileImageUrl = "profile_image_url_https"
    }
}

// MARK: - Profile image utilities
extension User {
    
    public enum ProfileImageSize: String {
        
        case mini = "_mini"
        case normal = "_normal"
        case bigger = "_bigger"
        case original = ""
    }
    
    /**
     Returns the url for the profile image of the user.
     
     - Parameter sizeCategory: The size category of the profile image.
    
     - Returns: The url of the user profile image that satisfies the given size category.
     */
    public func getProfileImage(sizeCategory: ProfileImageSize) -> URL? {
        
        let normal = ProfileImageSize.normal.rawValue
        
        let replacedPath = profileImageUrl.replacingOccurrences(of: normal, with: sizeCategory.rawValue)
        
        return URL(string: replacedPath)
    }
}
