// swift-tools-version:5.9

// Release CI 将本次二进制和受版本控制的资源复制到本清单旁，
// 以真实本地 binaryTarget 验证 SwiftPM 产品及资源 Target。

import PackageDescription

let package = Package(
    name: "YKIFLYADLibReleaseValidation",
    platforms: [
        .iOS("11.0"),
    ],
    products: [
        .library(name: "IFLYADLib", targets: ["IFLYADLib", "IFLYAdResources"]),
    ],
    targets: [
        .binaryTarget(
            name: "IFLYADLib",
            path: "IFLYADLib.xcframework"
        ),
        .target(
            name: "IFLYAdResources",
            path: "spm/IFLYAdResources",
            resources: [
                .copy("IFLYPlayer.bundle"),
            ],
            publicHeadersPath: "include"
        ),
    ]
)
