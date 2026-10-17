//
//  BasilCommand.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import ArgumentParser

@main
struct BasilCommand: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration
    = .init(commandName: "basil",
            abstract: abstract,
            version: BuildInfo.version)
    
    static var abstract: String {
        """
        Basil is a tool to help with managing GitHub and Gitea Issues, Pull Requests, and other features of the services' API
        """
    }
    
    mutating func run() async throws {
        
    }
}
