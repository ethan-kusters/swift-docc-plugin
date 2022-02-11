# ``SwiftDocCPlugin``

Produce Swift-DocC documentation for Swift Package libraries and executables.

## Overview

The Swift-DocC plugin is a Swift Package Manager command plugin that supports building
documentation for SwiftPM libraries and executables.

> Important: The Swift-DocC plugin is under **active-development** and is not ready for production
> use. 
> 
> We anticipate releasing a `1.0` version of the Swift-DocC plugin aligned with
> the release of Swift `5.6`.

After adding the plugin as a dependency in your Swift package manifest, you can build
documentation for the libraries and executables in that package and its dependencies by running the
following from the command-line:

    $ swift package generate-documentation

The documentation on this site is focused on the Swift-DocC plugin specifically. For more
general documentation on how to use Swift-DocC, see the documentation 
[here](https://www.swift.org/documentation/docc/).

## Topics

### Getting Started

- <doc:Getting-Started-with-the-Swift-DocC-Plugin>
- <doc:Generating-Documentation-for-a-Specific-Target>
- <doc:Previewing-Documentation>

### Publishing Documentation

- <doc:Generating-Documentation-for-Hosting-Online>
- <doc:Publishing-to-GitHub-Pages>

<!-- Copyright (c) 2022 Apple Inc and the Swift Project authors. All Rights Reserved. -->
