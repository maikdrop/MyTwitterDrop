/*
 MIT License

Copyright (c) 2021 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 Struct handles the user authentication for Twitter and adds the ability to store und load user credentials locally in the keychain.
 */

import OAuthSwift
import KeychainAccess
import Foundation

public struct Authentication {
    
    // MARK: - Properties
    private static let keychain = Keychain(service: service)
    private var consumerKey: String
    private var consumerSecret: String
    
    public static var loggedInUserId: String? {
        try? keychain.getString(Authentication.loggedUserIdKey)
    }
    
    // MARK: - Create a authorization
    public init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
}

// MARK: - Network request for checking user credentials
extension Authentication {
    
    /**
     Returns a new authentication object for Twitter requests.
     
     - Returns: An authentication object, which is needed for all Twitter requests and for the authorization of TwitterDrop.
     */
    public func newOauthObject() -> OAuth1Swift {
        
        OAuth1Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: TwitterAuthorization.requestTokenUrl,
            authorizeUrl: TwitterAuthorization.authorizeUrl,
            accessTokenUrl: TwitterAuthorization.accessTokenUrl)
    }
    
    /**
     Checks user credentials.
     
     - Parameter oauthObject: Object contains all necessary information for the authentication.
     - Parameter completion: The completion handler calls back with the authenticated user or an error when the authentication fails.
     */
    public static func checkUserCredentials(for ouathObject: OAuth1Swift, completion: @escaping (Result<User?, Error>) -> Void) {
        
        _ = ouathObject.client.get(credentialsAPI, parameters: [:]) { result in
            
            switch result {
            case .success(let response):
                
                if let user = User(json: response.data) {
                    
                    saveUserId(id: user.identifier)
                    
                    completion(.success(user))
                    
                } else {
                    
                    completion(.success(nil))
                }
                
            case .failure(let error):
    
                print(error.localizedDescription)
                
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Handles user credentials locally
extension Authentication {
    
    /**
     Returns an authentication object in order to authenticate the Twitter user for each request.
     
     - Returns: The authentication object, which contains locally loaded and valid user credentials.
     */
    public func loadUserCredentials() -> OAuth1Swift? {
       
        if let oauthToken = try? Self.keychain.getString(Authentication.tokenKey), let oauthTokenSecret = try? Self.keychain.getString(Authentication.secretTokenKey) {
            
            let oauthObject = newOauthObject()
            oauthObject.client.credential.oauthToken = oauthToken
            oauthObject.client.credential.oauthTokenSecret = oauthTokenSecret
            
            return oauthObject
        }
        return nil
    }
    
    /**
     Saves the user credentials into the Keychain.
     
     - Parameter token: The user token for the Twitter authentication.
     - Parameter tokenSecret: The user token secret for the Twitter authentication.
     */
    public static func saveCredentials(token: String, tokenSecret: String) {
        
        do {
            
            try keychain.set(token, key: tokenKey)
            try keychain.set(tokenSecret, key: secretTokenKey)
            
        } catch {
            print(error)
        }
    }
    
    /**
     Saves the user identifier into the Keychain.
     
     - Parameter id: The Twitter identifier of the authenticated user.
     */
    private static func saveUserId(id: String) {
       
        do {
            
           try keychain.set(id, key: loggedUserIdKey)
       
        } catch {
        
            print(error)
        }
    }
    
    /**
     Removes the credentials and the Twitter identifier of the authenticated user from the Keychain.
     */
    public static func removeCredentials() {
        
        do {

            try keychain.remove(tokenKey)
            try keychain.remove(secretTokenKey)
            try keychain.remove(loggedUserIdKey)
            
        } catch let error {
            
            print(error)
            
            Self.saveCredentials(token: "", tokenSecret: "")
            Self.saveUserId(id: "")
        }
    }
}

// MARK: - Constants
private extension Authentication {
    
    private static var tokenKey: String { "tokenKey" }
    private static var secretTokenKey: String { "secretTokenKey" }
    private static var loggedUserIdKey: String { "loggedUserID" }
    private static var service: String { "maikdrop.twitter-drop.twitter-token" }
    private static var credentialsAPI: String { "https://api.twitter.com/1.1/account/verify_credentials.json" }
}
