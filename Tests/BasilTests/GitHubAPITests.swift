import Testing
@testable import Basil

struct GitHubAPITests {
    @Test("Endpoint construction preserves paths and queries", arguments: [
        "user",
        "/user",
        "search/repositories?q=swift",
        "search/repositories?q=swift%20cli",
        "repos/a/b?label=",
        "repos/a/my..repo"
    ])
    func validEndpoint(endpoint: String) throws {
        let request = try GitHubAPI().request(endpoint: endpoint, method: .get)
        let path = endpoint.hasPrefix("/") ? endpoint : "/" + endpoint
        #expect(request.url?.absoluteString == "https://api.github.com" + path)
    }

    @Test("Dot segments and non-relative endpoints are rejected", arguments: [
        "../user",
        "repos/../user",
        "./user",
        "repos/./user",
        "%2E%2E/user",
        "repos/%2e/user",
        "repos%2F..%2Fuser",
        "https://example.com/user",
        "//example.com/user",
        "user#fragment",
        "",
        "   "
    ])
    func invalidEndpoint(endpoint: String) {
        #expect(throws: GitHubAPI.Error.self) {
            try GitHubAPI().request(endpoint: endpoint, method: .get)
        }
    }
}
