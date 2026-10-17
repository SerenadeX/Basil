//
//  HTTPClient.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import Foundation

final class HTTPClient {
    func perform(request: URLRequest) async throws -> String {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }

        let retryAfter = response
            .value(forHTTPHeaderField: "Retry-After")
            .flatMap(TimeInterval.init)

        let resetAt = response
            .value(forHTTPHeaderField: "X-RateLimit-Reset")
            .flatMap(TimeInterval.init)
            .map { Date(timeIntervalSince1970: $0) }

        let remaining = response
            .value(forHTTPHeaderField: "X-RateLimit-Remaining")
            .flatMap(Int.init)

        // GitHub can report rate limiting as either 429 or 403.
        let hasRateLimitSignal = remaining == 0 || retryAfter != nil
        let isForbiddenAndRateLimited =
            response.statusCode == 403 && hasRateLimitSignal
        let isRateLimited =
            response.statusCode == 429 || isForbiddenAndRateLimited

        if isRateLimited {
            throw Error.rateLimited(
                statusCode: response.statusCode,
                retryAfter: retryAfter,
                resetAt: resetAt
            )
        }

        guard (200..<300).contains(response.statusCode) else {
            throw Error.httpFailure(
                statusCode: response.statusCode,
                message: String(data: data, encoding: .utf8)
            )
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw Error.invalidResponseEncoding
        }

        return string
    }

    enum Error: Swift.Error {
        case invalidResponse
        case httpFailure(statusCode: Int, message: String?)
        case invalidResponseEncoding
        case rateLimited(
            statusCode: Int,
            retryAfter: TimeInterval?,
            resetAt: Date?
        )
    }
}
