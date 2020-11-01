//
//  File.swift
//  
//
//  Created by Ruslan Serebriakov on 5/5/20.
//

import Foundation
import TSCUtility

class Analyzer {
    let paths: [String]

    init(with paths: [String]) {
        self.paths = paths
    }

    var coverages: [Coverage] {
        do {
            var swiftFiles = 0
            var objcFiles = 0
            var swiftLines = 0
            var objcLines = 0
            var swiftClasses = 0
            var objcClasses = 0
            var swiftStructs = 0
            var objcStructs = 0

            for path in paths {
                let subpaths = try FileManager.default.subpathsOfDirectory(atPath: path)
                for subpath in subpaths {
                    if subpath.hasSuffix(".swift") {
                        swiftFiles += 1
                        swiftLines += numberOfLines(at: path + "/" + subpath) ?? 0
                        swiftClasses += numberOfOccurences(at: path + "/" + subpath, word: "class ") ?? 0
                        swiftStructs += numberOfOccurences(at: path + "/" + subpath, word: "struct ") ?? 0
                    } else if subpath.hasSuffix(".m") {
                        objcFiles += 1
                        objcLines += numberOfLines(at: path + "/" + subpath) ?? 0
                        objcStructs += numberOfOccurences(at: path + "/" + subpath, word: "typedef struct") ?? 0
                    } else if subpath.hasSuffix(".h") {
                        objcClasses += numberOfOccurences(at: path + "/" + subpath, word: "@interface") ?? 0
                        objcStructs += numberOfOccurences(at: path + "/" + subpath, word: "typedef struct") ?? 0
                    }
                }
            }

            let filesCoverage = FilesCountCoverage(swift: swiftFiles, objc: objcFiles)
            let linesCoverage = LinesCountCoverage(swift: swiftLines, objc: objcLines)
            let classesCoverage = ClassesCountCoverage(swift: swiftClasses, objc: objcClasses)
            let structsCoverage = StructsCountCoverage(swift: swiftStructs, objc: objcStructs)
            return [filesCoverage, linesCoverage, classesCoverage, structsCoverage]
        } catch {
            return []
        }
    }
}
