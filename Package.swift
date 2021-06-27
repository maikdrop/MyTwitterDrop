// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyTwitterDrop",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MyTwitterDrop",
            targets: ["MyTwitterDrop"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/OAuthSwift/OAuthSwift", from: "2.1.2"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MyTwitterDrop",
            dependencies: ["OAuthSwift", "KeychainAccess"]),
        .testTarget(
            name: "MyTwitterDropTests",
            dependencies: ["MyTwitterDrop"]),
    ]
)
