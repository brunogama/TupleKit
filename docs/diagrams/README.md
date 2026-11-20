# TupleKit diagrams

Start with [dependencies](dependencies.md), then open the function map for the target you are working on. GitHub or another Mermaid-capable Markdown viewer renders the diagrams.

---

## Function maps

| Target | Files | Swift callable declarations | Resolved function reference edges |
| --- | ---: | ---: | ---: |
| [TupleKit](TupleKit.md) | 21 | 79 | 122 |
| [TupleKitClient](TupleKitClient.md) | 2 | 1 | 7 |
| [TupleKitComposition](TupleKitComposition.md) | 3 | 9 | 6 |
| [TupleKitCompositionTests](TupleKitCompositionTests.md) | 5 | 21 | 107 |
| [TupleKitSnapshotTests](TupleKitSnapshotTests.md) | 1 | 9 | 29 |
| [TupleKitTests](TupleKitTests.md) | 18 | 127 | 564 |

- [Standalone Swift fixtures](fixtures.md): 19 compiler fixtures, parse-only.
- [Repository tooling](tooling.md): 10 shell/Python scripts, declaration containment only.

---

## Scope and evidence

- Snapshot: working tree based on `6ffa5fe`, including current uncommitted source.
- Codebase Memory index refreshed at `2026-11-19T09:11:49Z`. It reported seven partially parsed Swift files and its architecture output omitted Swift source imports, so its inferred Swift call edges are not used in these maps.
- The Swift maps use SourceKit indexing against all six SwiftPM targets on macOS, including macro-aware test indexing; coverage is by target source file, not a claim of complete runtime call discovery.
- The Swift parser supplemented the typed index with 10 explicitly declared callables labeled `syntax only`, such as local functions. Their references may be attributed to the indexed enclosing declaration, and no edges are inferred from syntax alone.
- Generic overloads are linked by compiler symbol ID where there is a unique local declaration. Dynamic dispatch, implicit/synthesized callables, macro expansion internals, and references the compiler index does not emit are not expanded. An unmapped node may be a standard-library or framework declaration, or a declaration outside the captured set.
- Resolved package dependencies and explicit Swift/Python imports are documented separately. Vendored dependencies, installed agent skills, generated files, and tool caches are outside the function maps.
