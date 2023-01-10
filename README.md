# coverage-reporter

This is small CLI tool that inspects the code coverage of an XCode test report (`.xcresult`) and creates a report out of it.

## Features / Planned Features

- [x] Compare the total coverage against a threshold
- [ ] Create an `lcov` report
- [ ] Create a single-file HTML report

## Install

This tool can be installed with the `swift package manager`:

```
dependencies: [
    // ...
    .package(url: "https://github.com/Tribe-GmbH/coverage-reporter"),
]
```

## Usage

```
$ coverage-reporter --help
OVERVIEW: A tool to extract, analyze and format coverage information from xcresult reports.

USAGE: coverage-reporter <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  verify                  Checks if the collected coverage is below the given threshold.

  See 'coverage-reporter help <subcommand>' for detailed help.
```

### Compare total coverage against threshold

The total coverage can be compared against a given threshold with the following command:

```
$ coverage-reporter verify /path/to/result.xcresult 95.5
```

This will read the `.xcresult` file, extract the coverage information from it and compare it with the threshold of `95.5%`.
When the threshold is not met the program ends with a non-zero exit code. This is especially useful in CI environments in order to make a CI run fail when the threshold is not met.

## FAQ

#### Why do we need another tool to create coverage reports?

There are a bunch of tools as for example [`slather`](https://github.com/SlatherOrg/slather) or [`xcov`](https://github.com/fastlane-community/xcov) both are not implemented in swift and therefore require extra tooling to install them. Additionally they don’t create a single-file HTML report, which is means the HTML report can’t be published on some CI systems (e.g. bitrise).

#### Is this compatible with `swift test`

Since `swift test` doesn’t generate a `.xcresult` folder this tool doesn’t support `swift test`. However a pull request to add support for this would be welcome’d.
