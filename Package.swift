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
            url: "https://download-adsdk.voiceads.cn/ios_sdk/6.5.2/youku/IFLYADLib.xcframework.zip",
            checksum: "f739875f170a2cde37de7a6ddcf330c1154d7ee57cf60bed2c19d71fc0a88b85"
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
