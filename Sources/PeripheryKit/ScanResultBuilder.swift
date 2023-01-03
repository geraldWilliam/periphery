import Foundation

public struct ScanResultBuilder {
    public static func build(for graph: SourceGraph) -> [ScanResult] {
        let assignOnlyProperties = graph.assignOnlyProperties
        let removableDeclarations = graph.unusedDeclarations.subtracting(assignOnlyProperties)
        let redundantProtocols = graph.redundantProtocols.filter { !removableDeclarations.contains($0.0) }
        let redundantPublicAccessibility = graph.redundantPublicAccessibility.filter { !removableDeclarations.contains($0.0) }
        let superfluouslyIgnoredDeclarations = graph.usedDeclarations.intersection(graph.commandIgnoredDeclarations)

        let annotatedRemovableDeclarations: [ScanResult] = removableDeclarations.map {
            .init(declaration: $0, annotation: .unused)
        }
        let annotatedAssignOnlyProperties: [ScanResult] = assignOnlyProperties.map {
            .init(declaration: $0, annotation: .assignOnlyProperty)
        }
        let annotatedRedundantProtocols: [ScanResult] = redundantProtocols.map {
            .init(declaration: $0.0, annotation: .redundantProtocol(references: $0.1))
        }
        let annotatedRedundantPublicAccessibility: [ScanResult] = redundantPublicAccessibility.map {
            .init(declaration: $0.0, annotation: .redundantPublicAccessibility(modules: $0.1))
        }
        let annotatedSuperfluouslyIgnoredDeclarations: [ScanResult] = superfluouslyIgnoredDeclarations.map {
            .init(declaration: $0, annotation: .superfluouslyIgnored)
        }
        let allAnnotatedDeclarations = annotatedRemovableDeclarations +
            annotatedAssignOnlyProperties +
            annotatedRedundantProtocols +
            annotatedRedundantPublicAccessibility +
            annotatedSuperfluouslyIgnoredDeclarations

        return allAnnotatedDeclarations
            .filter {
                !$0.declaration.isImplicit &&
                !$0.declaration.kind.isAccessorKind &&
                !graph.ignoredDeclarations.contains($0.declaration)
            }
    }
}
