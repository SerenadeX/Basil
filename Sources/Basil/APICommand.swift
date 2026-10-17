//
//  APICommand.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import ArgumentParser

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
        
        print("The method is \(method) and the host is \(host ?? "no host")")
        print("The endpoint is \(endpoint)")
    }
    
    func validate() throws {
        guard endpointIsValid
        else { throw ValidationError("Endpoint must have a non-empty, non-whitespace value") }
    }
    
    var endpointIsValid: Bool {
        endpoint.contains { !$0.isWhitespace }
    }
    
}

