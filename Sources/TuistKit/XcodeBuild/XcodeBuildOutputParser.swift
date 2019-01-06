import Foundation

/// Protocol that defines an interface to parse the xcodebuild output
protocol XcodeBuildOutputParsing {
    /// Parsers a line from the xcodebuild output and maps it into an XcodeBuildOutputEvent.
    ///
    /// - Parameter line: Line to be parsed.
    /// - Returns: Event that the line is associated to.
    func parse(line: String) -> XcodeBuildOutputEvent?
}

final class XcodeBuildOutputParser: XcodeBuildOutputParsing {
    // MARK: - Regular expressions

    private static let analyzeRegex = try! NSRegularExpression(pattern: "^Analyze(?:Shallow)?\\s(.*\\/(.*\\.(?:m|mm|cc|cpp|c|cxx)))\\s*",
                                                               options: [])
    private static let buildTargetRegex = try! NSRegularExpression(pattern: "^=== BUILD TARGET\\s(.*)\\sOF PROJECT\\s(.*)\\sWITH.*CONFIGURATION\\s(.*)\\s===",
                                                                   options: [])
    private static let aggregateTargetRegex = try! NSRegularExpression(pattern: "^=== BUILD AGGREGATE TARGET\\s(.*)\\sOF PROJECT\\s(.*)\\sWITH.*CONFIGURATION\\s(.*)\\s===",
                                                                       options: [])
    private static let analyzeTargetRegex = try! NSRegularExpression(pattern: "^=== ANALYZE TARGET\\s(.*)\\sOF PROJECT\\s(.*)\\sWITH.*CONFIGURATION\\s(.*)\\s===",
                                                                     options: [])
    private static let checkDependenciesRegex = try! NSRegularExpression(pattern: "^Check dependencies",
                                                                         options: [])
    private static let shellCommandRegex = try! NSRegularExpression(pattern: "^\\s{4}(cd|setenv|(?:[\\w\\/:\\\\s\\-.]+?\\/)?[\\w\\-]+)\\s(.*)$",
                                                                    options: [])
    private static let cleanRemoveRegex = try! NSRegularExpression(pattern: "^Clean.Remove",
                                                                   options: [])
    private static let cleanTargetRegex = try! NSRegularExpression(pattern: "^=== CLEAN TARGET\\s(.*)\\sOF PROJECT\\s(.*)\\sWITH CONFIGURATION\\s(.*)\\s===",
                                                                   options: [])
    private static let codeSignRegex = try! NSRegularExpression(pattern: "^CodeSign\\s((?:\\ |[^ ])*)$",
                                                                options: [])

    /// Parsers a line from the xcodebuild output and maps it into an XcodeBuildOutputEvent.
    ///
    /// - Parameter line: Line to be parsed.
    /// - Returns: Event that the line is associated to.
    func parse(line: String) -> XcodeBuildOutputEvent? {
        let range = NSRange(location: 0, length: line.count)
        let nsLine = NSString(string: line)

        // Analyze event
        if let match = XcodeBuildOutputParser.analyzeRegex.firstMatch(in: line,
                                                                      options: [],
                                                                      range: range) {
            let filePath = nsLine.substring(with: match.range(at: 1))
            let name = nsLine.substring(with: match.range(at: 2))
            return .analyze(filePath: filePath, name: name)
        } else if let match = XcodeBuildOutputParser.buildTargetRegex.firstMatch(in: line,
                                                                                 options: [],
                                                                                 range: range) {
            let target = nsLine.substring(with: match.range(at: 1))
            let project = nsLine.substring(with: match.range(at: 2))
            let configuration = nsLine.substring(with: match.range(at: 3))
            return .buildTarget(target: target, project: project, configuration: configuration)
        } else if let match = XcodeBuildOutputParser.aggregateTargetRegex.firstMatch(in: line,
                                                                                     options: [],
                                                                                     range: range) {
            let target = nsLine.substring(with: match.range(at: 1))
            let project = nsLine.substring(with: match.range(at: 2))
            let configuration = nsLine.substring(with: match.range(at: 3))
            return .aggregateTarget(target: target, project: project, configuration: configuration)
        } else if let match = XcodeBuildOutputParser.analyzeTargetRegex.firstMatch(in: line,
                                                                                   options: [],
                                                                                   range: range) {
            let target = nsLine.substring(with: match.range(at: 1))
            let project = nsLine.substring(with: match.range(at: 2))
            let configuration = nsLine.substring(with: match.range(at: 3))
            return .analyzeTarget(target: target, project: project, configuration: configuration)
        } else if XcodeBuildOutputParser.checkDependenciesRegex.firstMatch(in: line,
                                                                           options: [],
                                                                           range: range) != nil {
            return .checkDependencies
        } else if let match = XcodeBuildOutputParser.shellCommandRegex.firstMatch(in: line,
                                                                                  options: [],
                                                                                  range: range) {
            let path = nsLine.substring(with: match.range(at: 1))
            let arguments = nsLine.substring(with: match.range(at: 2))
            return .shellCommand(path: path, arguments: arguments)
        } else if XcodeBuildOutputParser.cleanRemoveRegex.firstMatch(in: line,
                                                                     options: [],
                                                                     range: range) != nil {
            return .cleanRemove
        } else if let match = XcodeBuildOutputParser.cleanTargetRegex.firstMatch(in: line,
                                                                                 options: [],
                                                                                 range: range) {
            let target = nsLine.substring(with: match.range(at: 1))
            let project = nsLine.substring(with: match.range(at: 2))
            let configuration = nsLine.substring(with: match.range(at: 3))
            return .cleanTarget(target: target, project: project, configuration: configuration)
        } else if let match = XcodeBuildOutputParser.codeSignRegex.firstMatch(in: line,
                                                                              options: [],
                                                                              range: range) {
            let path = nsLine.substring(with: match.range(at: 1))
            return .codeSign(path: path)
        }

        return nil
    }
}
