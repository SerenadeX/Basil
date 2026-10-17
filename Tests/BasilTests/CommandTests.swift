import Testing
@testable import Basil

struct CommandTests {
    @Test("API values parse without running the command", arguments: [false, true])
    func parsedValues(explicitOptions: Bool) throws {
        var arguments = ["repos/SerenadeX/Basil"]
        if explicitOptions {
            arguments += ["--method", "POST", "--host", "github"]
        }
        let command = try APICommand.parse(arguments)
        #expect(command.endpoint == "repos/SerenadeX/Basil")
        #expect(command.method == (explicitOptions ? .post : .get))
        #expect(command.host == (explicitOptions ? "github" : nil))
    }

    @Test("Root and API help", arguments: [[], ["api"]])
    func help(command: [String]) throws {
        let result = try runBasil(command + ["--help"])
        #expect(result.status == 0)
        #expect(result.error.isEmpty)
        #expect(result.output.contains("USAGE: basil"))
        #expect(result.output.contains("--help"))
        if command.isEmpty {
            #expect(result.output.contains("SUBCOMMANDS:"))
            #expect(result.output.contains("api"))
        } else {
            #expect(result.output.contains("<endpoint>"))
            #expect(result.output.contains("--method"))
            #expect(result.output.contains("--host"))
        }
    }

    @Test("Version exits before endpoint validation", arguments: [[], ["api"]])
    func version(command: [String]) throws {
        let result = try runBasil(command + ["--version"])
        #expect(result.status == 0)
        #expect(result.error.isEmpty)
        #expect(result.output == BuildInfo.version + "\n")
    }

    @Test("Method and host appear in output", arguments: HTTPMethod.allCases)
    func methodAndHost(method: HTTPMethod) throws {
        let result = try runBasil([
            "api", "repos/SerenadeX/Basil", "--method", method.rawValue,
            "--host", "github"
        ])
        #expect(result.status == 0)
        #expect(result.error.isEmpty)
        #expect(result.output.contains("The method is \(method) and the host is github"))
        #expect(result.output.contains("The endpoint is repos/SerenadeX/Basil"))
    }

    @Test("Omitted options use GET and no host")
    func defaultOptions() throws {
        let result = try runBasil(["api", "user"])
        #expect(result.status == 0)
        #expect(result.error.isEmpty)
        #expect(result.output.contains("The method is get and the host is no host"))
        #expect(result.output.contains("The endpoint is user"))
    }

    @Test("Missing endpoint is rejected")
    func missingEndpoint() throws {
        let result = try runBasil(["api"])
        #expect(result.status != 0)
        #expect(result.output.isEmpty)
        #expect(result.error.contains("Missing expected argument '<endpoint>'"))
    }

    @Test("Blank endpoints are rejected", arguments: ["", "   ", "\t", "\n", " \t\n"])
    func blankEndpoint(endpoint: String) throws {
        let result = try runBasil(["api", endpoint])
        #expect(result.status != 0)
        #expect(result.output.isEmpty)
        #expect(result.error.contains("Endpoint must have a non-empty, non-whitespace value"))
        #expect(result.error.contains("Usage:"))
    }

    @Test("Invalid and lowercase methods list valid choices", arguments: ["INVALID", "get", "", "123"])
    func invalidMethod(method: String) throws {
        let result = try runBasil(["api", "user", "--method", method])
        #expect(result.status != 0)
        #expect(result.output.isEmpty)
        #expect(result.error.contains("invalid for '--method"))
        for validMethod in HTTPMethod.allCases {
            #expect(result.error.contains(validMethod.rawValue))
        }
    }

    @Test("Malformed commands are rejected", arguments: [
        ["unknown"],
        ["api", "user", "--unknown"],
        ["api", "user", "--method"],
        ["api", "user", "--host"],
        ["api", "user", "extra-endpoint"]
    ])
    func malformedArguments(arguments: [String]) throws {
        let result = try runBasil(arguments)
        #expect(result.status != 0)
        #expect(result.output.isEmpty)
        #expect(result.error.contains("Error:"))
        #expect(result.error.contains("Usage:"))
    }
}
