//
//  HTTPMethod.swift
//  Basil
//
//  Created by Rhett Rogers on 10/17/26.
//

import ArgumentParser

enum HTTPMethod: String, Codable, ExpressibleByArgument, CaseIterable {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case trace = "TRACE"
}
