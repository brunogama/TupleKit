# Rename the package to TupleKit and remove the HeterogeneousBox alias

TupleKit 1.0.0 is the first release in the separate TupleKit repository. The package, products, and modules use the TupleKit and TupleKitComposition names. The deprecated `HeterogeneousBox` typealias for `Tuple` is not part of this release.

The module kept the old name at first, so the deprecated typealias and the module shared the name `HeterogeneousBox`. The name then resolved to the typealias, and `HeterogeneousBox.Tuple` could not qualify the type by module. A consumer whose own type is named `Tuple` had no clean way to name the library's type. With a module named TupleKit, `TupleKit.Tuple` works.

## Considered Options

- **Keep the old module name and remove the alias in a later release.** Rejected: module qualification stays broken, and the name keeps describing a "box" that the type no longer is.
- **Rename the module and keep the alias as deprecated.** Rejected: every HeterogeneousBox caller already has to change its dependency and its `import`, so a fix-it for the type name saves little, and the alias would keep the old name in the public API.

## Consequences

Migrating from HeterogeneousBox requires changing the dependency URL to `https://github.com/brunogama/TupleKit.git`, updating product names and imports, and replacing the old type name. The new repository's URL gives SwiftPM the TupleKit package identity for `.product(name: "TupleKit", package: "TupleKit")`. HeterogeneousBox is a separate repository, not a redirect.
