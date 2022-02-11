// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors

import Foundation
import PackagePlugin

/// Creates a Swift-DocC documentation archive from a Swift Package.
@main struct SwiftDocCConvert: DocCCommandPlugin {
    func performDocCCommand(context: PluginContext, arguments: [String]) throws {
        // We'll be creating commands that invoke `docc`, so start by locating it.
        let doccExecutableURL = try context.doccExecutable
        
        var argumentExtractor = ArgumentExtractor(arguments)
        let specifiedTargets = try argumentExtractor.extractSpecifiedTargets(in: context.package)
        
        let swiftSourceModuleTargets: [SwiftSourceModuleTarget]
        if specifiedTargets.isEmpty {
            swiftSourceModuleTargets = context.package.targets.relatedSwiftSourceModuleTargets
        } else {
            swiftSourceModuleTargets = specifiedTargets
        }
        
        // Parse the given command-line arguments
        let parsedArguments = ParsedArguments(argumentExtractor.remainingArguments)
        
        // If the `--help` or `-h` flag was passed, print the plugin's help information
        // and exit.
        guard !parsedArguments.help else {
            let helpInformation = try HelpInformation.forAction(
                .convert,
                doccExecutableURL: doccExecutableURL
            )
            
            print(helpInformation)
            return
        }
        
        // Iterate over the Swift source module targets we were given.
        for (index, target) in swiftSourceModuleTargets.enumerated() {
            if index != 0 {
                // Emit a line break if this is not the first target being built.
                print()
            }
            
            print("Generating documentation for '\(target.name)'...")
            
            // Ask SwiftPM to generate or update symbol graph files for the target.
            let symbolGraphDirectoryPath = try packageManager.getSymbolGraph(
                for: target,
                options: target.defaultSymbolGraphOptions(in: context.package)
            ).directoryPath.string
            
            // Construct the output path for the generated DocC archive
            let doccArchiveOutputPath = target.doccArchiveOutputPath(in: context)
            
            // Use the parsed arguments gathered earlier to generate the necessary
            // arguments to pass to `docc`. ParsedArguments will merge the flags provided
            // by the user with default fallback values for required flags that were not
            // provided.
            let doccArguments = parsedArguments.doccArguments(
                action: .convert,
                targetKind: target.representsExecutable(in: context.package) ? .executable : .library,
                doccCatalogPath: target.doccCatalogPath,
                targetName: target.name,
                symbolGraphDirectoryPath: symbolGraphDirectoryPath,
                outputPath: doccArchiveOutputPath
            )
            
            print("Converting documentation...")
            let conversionStartTime = DispatchTime.now()
            
            // Run `docc convert` with the generated arguments and wait until the process completes
            let process = try Process.run(doccExecutableURL, arguments: doccArguments)
            process.waitUntilExit()
            
            let conversionDuration = conversionStartTime.distance(to: .now())
            
            // Check whether the `docc convert` invocation was successful.
            if process.terminationReason == .exit && process.terminationStatus == 0 {
                print("Conversion complete! (\(conversionDuration.descriptionInSeconds))")
                
                let describedOutputPath = doccArguments.outputPath ?? "unknown location"
                print("Generated DocC archive at '\(describedOutputPath)'")
            } else {
                Diagnostics.error("""
                    'docc convert' invocation failed with a nonzero exit code: '\(process.terminationStatus)'
                    """
                )
            }
        }
    }
}
