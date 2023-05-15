# GitHubAPI

## 🤔 What? 
iOS15 부터 지원하는 비동기 메써드인 URLSession.shared.data 을 사용해서 네트워크를 구현했습니다.

## 💻 Code
```swift
static let baseUrl = "https://api.github.com"

static func getUser(username: String) async throws -> GitHubUser {
    let urlString = baseUrl + "/users" + "/\(username)"
    let data = try await API.request(urlString: urlString, method: .get)
    return try API.parse(type: GitHubUser.self, data: data)
}
```

## 📚 참고
- [Apple URLSession 문서](https://developer.apple.com/documentation/foundation/urlsession/3767352-data)
- [Githib API 문서](https://docs.github.com/en/rest/users/users?apiVersion=2022-11-28)
