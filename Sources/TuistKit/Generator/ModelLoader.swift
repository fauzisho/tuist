import Foundation
import Basic

/// Entity responsible for providing generator models
///
/// Assumptions:
///   - TuistGenerator creates a graph of Project dependencies
///   - The projects are associated with unique paths
///   - Each path only contains one Project
///   - Whenever a dependency is encountered referencing another path,
///     this entity is consulted again to load the model at that path
protocol GeneratorModelLoading {

    var environmentPath: AbsolutePath? { get set }

    /// Load a Project model at the specified path
    ///
    /// - Parameter path: The absolute path for the project modal to load
    /// - Returns: The Project loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing project)
    func loadProject(at path: AbsolutePath) throws -> Project
    
    /// Load a Workspace model at the specified path
    ///
    /// - Parameter path: The absolute path for the workspace modal to load
    /// - Returns: The workspace loaded from the specified path
    /// - Throws: Error encountered during the loading process (e.g. Missing workspace)
    func loadWorkspace(at path: AbsolutePath) throws -> Workspace
}
