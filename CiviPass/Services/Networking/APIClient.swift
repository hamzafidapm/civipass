import Foundation

/// Abstraction over remote requests, used for future content sync (e.g. official
/// question bank updates). CiviPass is offline-first; this is not on the critical path yet.
protocol APIClientProtocol {
    func get<T: Decodable>(_ endpoint: String) async throws -> T
}

struct APIClient: APIClientProtocol {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = .shared, baseURL: URL = URL(string: "https://api.civipass.app")!) {
        self.session = session
        self.baseURL = baseURL
    }

    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
