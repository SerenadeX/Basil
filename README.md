# Basil

A Swift command-line tool for accessing GitHub and Gitea APIs.

Basil is in early development. It currently parses commands, displays help and
version information, and validates API arguments. The `api` command prints the
selected inputs; it does not make HTTP requests or authenticate yet.

## Requirements

- Swift 6.0 or later. Development and tests have been verified on macOS with Swift 6.4 and Xcode 27.1.
- Xcode with a compatible Swift toolchain for the Xcode workflow below.

The first build resolves Swift Argument Parser and requires internet access.

## Build and run

From the repository root:

```sh
swift build
swift run Basil --help
swift run Basil --version
swift run Basil api --help
swift run Basil api repos/SerenadeX/Basil --method GET --host github
```

`Basil` is the current SwiftPM executable product name. Generated help uses the
command name `basil`.

Basil targets GitHub's REST API version `2026-03-10` using the
`X-GitHub-Api-Version` request header. This is separate from Basil's own
application version. See [GitHub API versioning][github-api-versions] for the
supported versions and compatibility policy.

[github-api-versions]:
  https://docs.github.com/en/rest/about-the-rest-api/api-versions

The endpoint is required and positional. `--method` defaults to `GET`; accepted
values are `GET`, `HEAD`, `POST`, `PUT`, `PATCH`, `DELETE`, `OPTIONS`, `CONNECT`,
and `TRACE`. Methods are case-sensitive. `--host` is optional and currently only
echoed in output; host profiles are not implemented.

## Run in Xcode

1. Open `Package.swift` in Xcode and allow dependency resolution to finish.
2. Select the Basil scheme and My Mac as the run destination.
3. Open Product > Scheme > Edit Scheme > Run > Arguments.
4. Add enabled argument rows such as `api`, `user`, `--method`, and `GET`.
5. Press Command-R and view the output in the debug console.

If the package navigator appears empty, fully quit Xcode with Command-Q and
reopen `Package.swift`.

## Run tests

```sh
swift test
```

The suite uses Swift Testing to cover direct argument parsing, root and API
help, version output, methods and hosts, defaults, and invalid input. Process
tests launch the built executable and check stdout, stderr, and exit status.
No credentials or live API calls are needed. Dependency resolution may still
require internet access on the first run.

In Xcode, select the Basil scheme and press Command-U to run tests.

To manually check invalid endpoints, use Terminal so an empty argument is
preserved reliably:

```sh
swift run Basil api
swift run Basil api ""
swift run Basil api "   "
```

These cover a missing endpoint, an explicitly empty endpoint, and a
whitespace-only endpoint. Each should fail with an error and a nonzero exit status.
