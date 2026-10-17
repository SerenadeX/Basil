//
//  GitHubAPI.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import Foundation

class GitHubAPI {
    private static let apiVersion = "2026-03-10"
    
    
    func request(endpoint: String,
                 method: HTTPMethod) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: endpoint),
              urlComponents.scheme == nil,
              urlComponents.host == nil,
              urlComponents.fragment == nil,
              !urlComponents.path
                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { throw Error.invalidEndpointFormat }

        // Check the decoded path so encoded dot segments are rejected too.
        let pathSegments = urlComponents.path.split(separator: "/")
        guard !pathSegments.contains(where: { $0 == "." || $0 == ".." }) else {
            throw Error.invalidEndpointFormat
        }

        // Preserve existing encoding and query syntax.
        if !urlComponents.percentEncodedPath.hasPrefix("/") {
            urlComponents.percentEncodedPath =
                "/" + urlComponents.percentEncodedPath
        }
        urlComponents.scheme = "https"
        urlComponents.host = "api.github.com"

        guard let url = urlComponents.url else {
            throw BasilError.urlFormatIsIncorrect
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(
            "application/vnd.github+json",
            forHTTPHeaderField: "Accept"
        )
        urlRequest.setValue(
            "Basil/\(BuildInfo.version)",
            forHTTPHeaderField: "User-Agent"
        )
        urlRequest.setValue(
            Self.apiVersion,
            forHTTPHeaderField: "X-GitHub-Api-Version"
        )
        return urlRequest
    }
    
    enum Error: Swift.Error {
        case invalidEndpointFormat
    }
    
}
