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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.3-beta.1/youku/IFLYADLib.xcframework.zip",
            checksum: "1b8ef5f3670d1d675a038367bcb494ff65a235315680beec3383947c655a5a7b"
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
