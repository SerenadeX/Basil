//
//  APICommand.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import ArgumentParser
import Foundation

struct APICommand: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = CommandConfiguration
        .init(commandName: "api",
              abstract: "Call a specific endpoint of the api")
    
    @Option(help: "HTTP Method to Use")
    var method: HTTPMethod = .get
    
    @Option(help: "Host to connect to")
    var host: String?
    
    @Argument(help: "The endpoint to talk to")
    var endpoint: String
    
    mutating func run() async throws {
        let api = GitHubAPI()
        let request = try api
            .request(endpoint: endpoint,
                     method: method)
        let responseString = try await HTTPClient()
            .perform(request: request)
        print(responseString)
    }
    
    func validate() throws {
        guard endpointIsValid
        else { throw ValidationError("Endpoint must have a non-empty, non-whitespace value") }
        guard method == .get else {
            throw ValidationError("Only GET is supported right now.")
        }
        guard host == "github" || host == nil else {
            throw ValidationError(
                "Only the github host is currently supported; " +
                "omit --host or use --host github."
            )
        }
    }
    
    var endpointIsValid: Bool {
        endpoint.contains { !$0.isWhitespace }
    }
    
}

