# Overview

## Author

* **Maik Müller** *Applied Computer Science (M. Sc.)* - [LinkedIn](https://www.linkedin.com/in/maik-m-253357107), [Xing](https://www.xing.com/profile/Maik_Mueller215/cv)

### 1. Description

It's a small library to capsule the network communication with Twitter for an iOS Client. It uses the standard v1.1 API and the OAuth 1.0a authentication method in order to fetch data from Twitter. It can be directly imported into Xcode as a Swift Package. 

Dependencies: [OAuthSwift](https://github.com/OAuthSwift/OAuthSwift), [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)

### 2. Features

  - app authorization and Twitter user authentication
  - saving and fetching user credentials in and from Keychain
  - fetching the home timeline for the authenticated user
  - search for tweets

### 3. Code Examples

Request a user home timeline:

```swift
let request = Request(oauthSwift: oauthSwift, count: tweetCountToFetch)
```

Search for specific tweets:

```swift
let request = Request(oauthSwift: oauthSwift, search: searchText, count: tweetCountToFetch)
```

Fetch tweets:

```swift
request.fetchTweets() { [weak self] newTweets in
  
  // process the requested tweets
  
}
```

### 4. Source

MyTwitterDrop based on the library that was originally included in [Stanford - Developing iOS 10 Apps with Swift - 9. Table View](https://www.youtube.com/watch?v=Sm3jupdLJBY). It was rewritten by the author for custom purpose.

Additionally, following parts have been added:

  - JSON parsing for tweets and their entities
  - authorization and authentication
  - Keychain access

**Note**

The libarary wasn't tested systematically.
