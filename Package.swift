// swift-tools-version:5.9

// 优酷定制 Model B 单包。二进制模块名保持 IFLYADLib。
// 静态 binaryTarget 不会投递外置 IFLYPlayer.bundle，因此产品同时包含资源 target；
// SDK 会从 SwiftPM 生成的资源 bundle 中定位其内嵌的 IFLYPlayer.bundle。

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
            url: "https://github.com/LJMcarryu/YKIFLYADLib_iOS/releases/download/6.2.4/IFLYADLib.xcframework.zip",
            // 6.2.4 冻结签名 zip 的 SwiftPM 校验值。
            checksum: "ce27b5d98a925c109fa6355a8095db7201717c7e1b9b2bcbbb92265dc2272d5e"
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
