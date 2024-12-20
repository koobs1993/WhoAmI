// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WhoAmI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "WhoAmI",
            targets: ["Models", "Features"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.3.1"),
        .package(url: "https://github.com/supabase-community/gotrue-swift.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "GoTrue", package: "gotrue-swift")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "Features",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "GoTrue", package: "gotrue-swift"),
                "Models"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
