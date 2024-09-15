// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "EBUniAppsKit",
    platforms: [
        .iOS(.v17), .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EBUniAppsKit",
            targets: ["EBUniAppsKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EBUniAppsKit",
            dependencies: [
                "EBUniAppsKitMacros"
            ]),
        .testTarget(
            name: "EBUniAppsKitTests",
            dependencies: ["EBUniAppsKit"]),

        
        // MARK: - SwiftUI Macros
        .macro(
            name: "EBUniAppsKitMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .executableTarget(name: "EBUniAppsKitMacros_Client",
                          dependencies: ["EBUniAppsKit"]),
        .testTarget(
            name: "EBUniAppsKitMacros_Tests",
            dependencies: [
                "EBUniAppsKit",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
