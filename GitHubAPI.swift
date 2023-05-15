import Foundation

struct API {
    
    static func request(
        urlString: String,
        method: HttpMethod,
        header: [String: String]? = nil,
        body: [String: Any]? = nil) async throws -> Data {
            let request = try urlRequest(urlString: urlString, method: method, header: header, body: body)
            return try await execute(request: request)
    }
    
    static func urlRequest(
        urlString: String,
        method: HttpMethod,
        header: [String: String]? = nil,
        body: [String: Any]? = nil
    ) throws -> URLRequest {
        guard let url = URL(string: urlString) else { throw NetworkError.urlNotFound }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let header {
            header.forEach { request.addValue($0.key, forHTTPHeaderField: $0.value) }
        }
        if let body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        return request
    }
    
    static func execute(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode)
        else { throw NetworkError.badResponse }
        return data
    }
    
    static func parse<T: Decodable>(type: T.Type, data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }
    
    static func jsonify(data: Data) throws -> [String: Any] {
        guard let result = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { throw NetworkError.failedJsonify }
        return result
    }
}

enum NetworkError: Error {
    case urlNotFound, badResponse, failedJsonify
}

enum HttpMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}

struct GithubAPI {
    
    static let baseUrl = "https://api.github.com"
    
    static func getUser(username: String) async throws -> GitHubUser {
        let urlString = baseUrl + "/users" + "/\(username)"
        let data = try await API.request(urlString: urlString, method: .get)
        return try API.parse(type: GitHubUser.self, data: data)
    }
}

struct GitHubUser: Codable {
    let login: String
    let url: String
    let name: String
    let followers: Int
    let following: Int
}

Task {
    let user = try await GithubAPI.getUser(username: "insub4067")
    print(user)
    //    출력 👇👇
    //    GitHubUser(login: "insub4067", url: "https://api.github.com/users/insub4067", name: "insub", followers: 105, following: 128)
}


// MARK: - Recieved JSON Data
//[
//    "company": Social Investing Lab,
//    "html_url": https://github.com/insub4067,
//    "login": insub4067,
//    "repos_url": https://api.github.com/users/insub4067/repos,
//    "bio": iOS Developer,
//    "followers": 105,
//    "organizations_url": https://api.github.com/users/insub4067/orgs,
//    "blog": https://insubkim.tistory.com/,
//    "following_url": https://api.github.com/users/insub4067/following{/other_user},
//    "created_at": 2021-06-07T07:37:55Z,
//    "followers_url": https://api.github.com/users/insub4067/followers,
//    "gists_url": https://api.github.com/users/insub4067/gists{/gist_id},
//    "updated_at": 2023-04-24T01:17:10Z,
//    "following": 128,
//    "location": korea,
//    "public_gists": 1,
//    "node_id": MDQ6VXNlcjg1NDgxMjA0,
//    "url": https://api.github.com/users/insub4067,
//    "subscriptions_url": https://api.github.com/users/insub4067/subscriptions,
//    "events_url": https://api.github.com/users/insub4067/events{/privacy},
//    "hireable": <null>,
//    "received_events_url": https://api.github.com/users/insub4067/received_events,
//    "id": 85481204,
//    "email": <null>,
//    "twitter_username": <null>,
//    "starred_url": https://api.github.com/users/insub4067/starred{/owner}{/repo},
//    "avatar_url": https://avatars.githubusercontent.com/u/85481204?v=4,
//    "site_admin": 0,
//    "type": User,
//    "name": insub,
//    "public_repos": 66,
//    "gravatar_id":
//]
//
