// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors

import Foundation
@testable import SwiftDocCPluginUtilities
import XCTest

final class SkipSynthesizedSymbolsFlagTests: XCTestCase {
    func testNotTransformExistingFlagsWhenPresent() {
        XCTAssertEqual(
            PluginFlag.skipSynthesizedSymbols.transform(
                ["--index", "--other-flag"]
            ),
            ["--index", "--other-flag"]
        )
    }
}
