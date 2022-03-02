// swift-tools-version:5.6
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftDocCPlugin",
    platforms: [
        .macOS("10.15.4"),
    ],
    products: [
        .plugin(name: "Swift-DocC", targets: ["Swift-DocC"]),
        .plugin(name: "Swift-DocC Preview", targets: ["Swift-DocC Preview"]),
    ],
    targets: [
        .plugin(
            name: "Swift-DocC",
            capability: .command(
                intent: .documentationGeneration()
            ),
            path: "Plugins/Swift-DocC Convert",
            exclude: ["Symbolic Links/README.md"]
        ),
        
        .plugin(
            name: "Swift-DocC Preview",
            capability: .command(
                intent: .custom(
                    verb: "preview-documentation",
                    description: "Preview the Swift-DocC documentation for a specified target."
                )
            ),
            exclude: ["Symbolic Links/README.md"]
        ),
        
        .target(name: "SwiftDocCPluginUtilities"),
        .testTarget(
            name: "SwiftDocCPluginUtilitiesTests",
            dependencies: [
                "SwiftDocCPluginUtilities",
            ],
            resources: [
                .copy("Test Fixtures"),
            ]
        ),
        
        // Empty target that builds the DocC catalog at /SwiftDocCPluginDocumentation/SwiftDocCPlugin.docc.
        // The SwiftDocCPlugin catalog includes high-level, user-facing documentation about using
        // the Swift-DocC plugin from the command-line.
        .target(
            name: "SwiftDocCPlugin",
            path: "Sources/SwiftDocCPluginDocumentation",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "snippet-build",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SymbolKit", package: "swift-docc-symbolkit"),
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
            ])
    ]
)

if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-symbolkit", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "1.0.1")),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .branch("main")),
    ]
} else {
    package.dependencies += [
        .package(name: "SymbolKit", path: "../swift-docc-symbolkit"),
        .package(path: "../swift-argument-parser"),
        .package(path: "../swift-tools-support-core"),
    ]
}
