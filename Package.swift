// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftNpy",
    dependencies: [
        .Package(url: "https://github.com/t-ae/swift-zip.git", versions: Version(0, 0, 0)..<Version(1, 0, 0))
    ]
)
