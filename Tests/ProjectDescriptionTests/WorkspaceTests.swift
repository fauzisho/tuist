import Foundation
import XCTest
@testable import ProjectDescription

final class WorkspaceTests: XCTestCase {
    func test_toJSON() throws {
        let subject = Workspace(name: "name", projects: ["/path/to/project"])

        let expected =
            """
            {
               "name":"name",
               "projects": [
                  "/path/to/project"
               ],
               "additionalFiles": [
               ]
            }
            """

        assertCodableEqualToJson(subject, expected)
    }

    func test_toJSON_withAdditionalFiles() throws {
        let subject = Workspace(name: "name",
                                projects: ["ProjectA"],
                                additionalFiles: [
                                    .glob(pattern: "Documentation/**"),
                                ])

        let expected =
            """
            {
               "name":"name",
               "projects": [
                  "ProjectA"
               ],
               "additionalFiles": [
                    {
                        "type": "glob",
                        "pattern": "Documentation/**"
                    }
               ]
            }
            """

        assertCodableEqualToJson(subject, expected)
    }
}
