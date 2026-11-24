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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.4/youku/IFLYADLib.xcframework.zip",
            checksum: "38de9a35d6f636f07f13fd0a8b09ea75d15f7b70aca04cf8e65c90d79512a753"
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
