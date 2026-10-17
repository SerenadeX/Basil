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
    var method: String = "GET"
    
    @Option(help: "Host to connect to")
    var host: String?
    
    mutating func run() async throws {
        print("The method is \(method) and the host is \(host ?? "no host")")
    }
    
}

