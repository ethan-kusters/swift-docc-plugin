// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors

import PackagePlugin

extension Target {
    var asSwiftSourceModuleTarget: SwiftSourceModuleTarget? {
        return self as? SwiftSourceModuleTarget
    }
}

extension Array where Element == Target {
    /// Returns all related Swift source module targets in the current array of targets.
    ///
    /// This includes any Swift source module targets that are directly included in the array
    /// as well as those target's Swift dependencies.
    var relatedSwiftSourceModuleTargets: [SwiftSourceModuleTarget] {
        // First filter to just the Swift source module targets
        let swiftTargets = Set(self.compactMap(\.asSwiftSourceModuleTarget))
        
        // Then find all the Swift source module targets that are dependencies of those
        let swiftTargetDependencies = swiftTargets.flatMap(\.swiftSourceModuleTargetDependencies)
        
        let allUniqueTargets = swiftTargets.union(swiftTargetDependencies)
        
        return allUniqueTargets.sorted { lhs, rhs in
            lhs.name < rhs.name
        }
    }
}

fileprivate extension SwiftSourceModuleTarget {
    /// Any Swift source module targets on which this target depends.
    var swiftSourceModuleTargetDependencies: Set<SwiftSourceModuleTarget> {
        return Set(
            dependencies.flatMap { dependency -> [SwiftSourceModuleTarget] in
                switch dependency {
                case .target(let target):
                    // For any targets that we depend on, we should include that target and
                    // its dependencies since these are all in the same package.
                    guard let swiftSourceModuleTarget = target as? SwiftSourceModuleTarget else {
                        return []
                    }
                    
                    return [swiftSourceModuleTarget] + swiftSourceModuleTarget.swiftSourceModuleTargetDependencies
                case .product(let product):
                    // When we depend on a product in another target, we shouldn't recurse further,
                    // just include the immediately exposed targets.
                    return product.targets.compactMap(\.asSwiftSourceModuleTarget)
                @unknown default:
                    return []
                }
            }
        )
    }
}

extension SwiftSourceModuleTarget: Hashable {
    public static func == (lhs: SwiftSourceModuleTarget, rhs: SwiftSourceModuleTarget) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
