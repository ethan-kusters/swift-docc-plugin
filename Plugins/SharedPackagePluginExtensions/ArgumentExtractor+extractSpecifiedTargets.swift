// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors

import Foundation
import PackagePlugin

enum ArgumentParsingError: LocalizedError {
    case unknownProduct(String)
    case unknownTarget(String)
    case productDoesNotContainSwiftSourceModuleTargets(String)
    case targetIsNotSwiftSourceModule(String)
    
    var errorDescription: String? {
        switch self {
        case .unknownProduct(let string):
            return "no product named '\(string)'"
        case .unknownTarget(let string):
            return "no target named '\(string)'"
        case .productDoesNotContainSwiftSourceModuleTargets(let string):
            return "product '\(string)' does not contain any Swift source modules"
        case .targetIsNotSwiftSourceModule(let string):
            return "target '\(string)' is not a Swift source module"
        }
    }
}

extension ArgumentExtractor {
    mutating func extractSpecifiedTargets(in package: Package) throws -> [SwiftSourceModuleTarget] {
        let specifiedProducts = extractOption(named: "product")
        let specifiedTargets = extractOption(named: "target")
        
        let productTargets = try specifiedProducts.flatMap { specifiedProduct -> [SwiftSourceModuleTarget] in
            let product = package.allProducts.first { product in
                product.name == specifiedProduct
            }
            
            guard let product = product else {
                throw ArgumentParsingError.unknownProduct(specifiedProduct)
            }
            
            let swiftSourceModuleTargets = product.targets.compactMap { target in
                target as? SwiftSourceModuleTarget
            }
            
            guard !swiftSourceModuleTargets.isEmpty else {
                throw ArgumentParsingError.productDoesNotContainSwiftSourceModuleTargets(specifiedProduct)
            }
            
            return swiftSourceModuleTargets
        }
        
        let targets = try specifiedTargets.map { specifiedTarget -> SwiftSourceModuleTarget in
            let target = package.targets.first { target in
                target.name == specifiedTarget
            }
            
            guard let target = target else {
                throw ArgumentParsingError.unknownTarget(specifiedTarget)
            }
            
            guard let swiftSourceModuleTarget = target as? SwiftSourceModuleTarget else {
                throw ArgumentParsingError.targetIsNotSwiftSourceModule(specifiedTarget)
            }
            
            return swiftSourceModuleTarget
        }
        
        return productTargets + targets
    }
}

private extension Package {
    /// Any regular products defined in this package and its dependencies.
    var allProducts: [Product] {
        products + dependencies.flatMap(\.package.products)
    }
}
