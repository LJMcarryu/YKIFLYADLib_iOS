// swift-tools-version:5.9

// 优酷定制 SDK，导入模块名为 IFLYADLib；product 自动包含资源。
// 在宿主 App target 的 Other Linker Flags 中添加 -ObjC。

import PackageDescription

let package = Package(
    name: "YKIFLYADLib",
    platforms: [
        .iOS("11.0"),
    ],
    products: [
        .library(name: "IFLYADLib", targets: ["IFLYADLib", "IFLYAdResources"]),
    ],
    targets: [
        .binaryTarget(
            name: "IFLYADLib",
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.0/youku/IFLYADLib.xcframework.zip",
            checksum: "f30a0e763813c31b09b81156bd34b05d51b04ae0070d2236bb6977d06ac221e8"
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
