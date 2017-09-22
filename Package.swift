import PackageDescription

let package = Package(
    name: "tmp",
    targets: [
      Target(name: "tmp", dependencies: [ .Target(name: "Application") ]),
      Target(name: "Application", dependencies: [
            .Target(name: "Generated"),
      ]),
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git",             majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git",       majorVersion: 1, minor: 7),
        .Package(url: "https://github.com/IBM-Swift/Health.git",             majorVersion: 0),
        .Package(url: "https://github.com/IBM-Swift/CloudConfiguration.git", majorVersion: 2),
        .Package(url: "https://github.com/RuntimeTools/SwiftMetrics.git", majorVersion: 1),

    ],
    exclude: ["src"]
)
