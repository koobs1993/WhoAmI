// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WhoAmI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WhoAmI",
            targets: ["WhoAmI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "1.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.6")
    ],
    targets: [
        .target(
            name: "WhoAmI",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI")
            ],
            path: "WhoAmI",
            exclude: [
                "Info.plist",
                "Preview Content/Preview Assets.xcassets",
                "Resources/Assets.xcassets",
                "WhoAmI.entitlements"
            ],
            resources: [
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "WhoAmITests",
            dependencies: ["WhoAmI"]),
    ]
) 