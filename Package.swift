// swift-tools-version: 5.9
// ForexMindGuard – Swift Package Manager manifest
// Defines third-party dependencies for the iOS + Watch app.
//
// NOTE: This file is kept at the repo root so that SPM can be used standalone
// for the library/service layer.  The Xcode project (ForexMindGuard.xcodeproj)
// references these packages via "Add Package Dependency".

import PackageDescription

let package = Package(
    name: "ForexMindGuard",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "ForexMindGuard",
            targets: ["ForexMindGuard"]
        )
    ],
    dependencies: [
        // WebSocket client – used by ForexWebSocketService
        .package(
            url: "https://github.com/daltoniam/Starscream.git",
            from: "4.0.6"
        ),
        // OpenAI Swift client – used by AIExplainerService
        // TODO: replace with official OpenAI SDK once generally available
        .package(
            url: "https://github.com/MacPaw/OpenAI.git",
            from: "0.2.4"
        ),
        // Firebase iOS SDK (Auth + Firestore) – optional backend
        // Uncomment when backend integration is needed:
        // .package(
        //     url: "https://github.com/firebase/firebase-ios-sdk.git",
        //     from: "10.0.0"
        // ),
    ],
    targets: [
        .target(
            name: "ForexMindGuard",
            dependencies: [
                "Starscream",
                "OpenAI",
            ],
            path: "ForexMindGuard"
        ),
        .testTarget(
            name: "ForexMindGuardTests",
            dependencies: ["ForexMindGuard"],
            path: "ForexMindGuardTests"
        ),
    ]
)
