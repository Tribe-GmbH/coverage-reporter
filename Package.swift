// swift-tools-version:5.7

import PackageDescription

private func createTarget(name: String, dependencies: [Target.Dependency] = []) -> Target {
    return Target.target(
        name: name,
        dependencies: dependencies,
        path: name,
        plugins: []
    )
}

private func createExecutableTarget(name: String, dependencies: [Target.Dependency] = []) -> Target {
    return Target.executableTarget(
        name: name,
        dependencies: dependencies,
        path: name,
        plugins: []
    )
}

private func createTestTarget(name: String, dependencies: [Target.Dependency] = [], exclude: [String] = []) -> Target {
    let allDependencies = dependencies + [
        .product(name: "Quick", package: "Quick"),
        .product(name: "Nimble", package: "Nimble")
    ]

    return Target.testTarget(
        name: name,
        dependencies: allDependencies,
        path: name,
        exclude: exclude,
        plugins: []
    )
}

private func createUnitTestTarget(forTargetUnderTest: String, dependencies: [Target.Dependency] = []) -> Target {
    let testTargetName = "\(forTargetUnderTest)UnitTests"
    let allDependencies = dependencies + [
        .target(name: forTargetUnderTest)
    ]

    return createTestTarget(name: testTargetName, dependencies: allDependencies)
}

let package = Package(
    name: "coverage-reporter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "coverage-reporter",
            targets: ["CoverageReporterCli"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/davidahouse/XCResultKit", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/Quick/Quick", from: "6.1.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "11.2.1"),
        .package(url: "https://github.com/realm/SwiftLint", revision: "74dbd52adda90eee0313654d876fdf88c8325552"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.7")
    ],
    targets: [
        createExecutableTarget(
            name: "CoverageReporterCli",
            dependencies: [
                "CoverageReader",
                "CoverageAnalyzer",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        createUnitTestTarget(forTargetUnderTest: "CoverageReporterCli", dependencies: ["CoverageAnalyzer"]),
        createTarget(
            name: "CoverageReader",
            dependencies: [.product(name: "XCResultKit", package: "XCResultKit")]
        ),
        createUnitTestTarget(
            forTargetUnderTest: "CoverageReader",
            dependencies: [.product(name: "XCResultKit", package: "XCResultKit")]
        ),
        createTarget(
            name: "CoverageAnalyzer",
            dependencies: [.product(name: "XCResultKit", package: "XCResultKit"), "CoverageReader"]
        ),
        createUnitTestTarget(
            forTargetUnderTest: "CoverageAnalyzer",
            dependencies: [.product(name: "XCResultKit", package: "XCResultKit"), "CoverageReader"]
        ),
        createTestTarget(
            name: "CliIntegrationTests",
            exclude: ["fixtures"]
        )
    ]
)
