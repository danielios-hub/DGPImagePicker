// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DGPImagePicker",
    platforms: [
       .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "DGPImagePicker",
            type: .dynamic,
            targets: ["DGPImagePicker"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "DGPLibrary", url: "https://daniel_ios@bitbucket.org/daniel_ios/dgplibrary.git", .branch("master")),
        .package(name: "DGPExtensionCore", url: "https://daniel_ios@bitbucket.org/daniel_ios/dgpextensioncore.git", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "DGPImagePicker",
            dependencies: ["DGPLibrary", "DGPExtensionCore"]),
        .testTarget(
            name: "DGPImagePickerTests",
            dependencies: ["DGPImagePicker"]),
    ]
)
