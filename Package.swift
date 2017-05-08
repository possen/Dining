// swift-tools-version:3.1

import PackageDescription

let package = Package(
   	 	name: "Dining",
		targets:[],
        dependencies: [
        	.Package(url: "https://github.com/thoughtbot/Argo.git", majorVersion:4),
        	.Package(url: "https://github.com/thoughtbot/Curry.git", majorVersion:3)
    ]
)
