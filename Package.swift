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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3/youku/IFLYADLib.xcframework.zip",
            checksum: "a0c775e69eb7b5acb486094ce4db6da9fba7a8627f7068229378f3a2c5c2a297"
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
