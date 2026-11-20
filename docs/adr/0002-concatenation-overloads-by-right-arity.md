# Concatenation is overloaded by right-hand arity

`+` joins a variadic left tuple with a right tuple of one to six members, through generated overloads, instead of one overload that joins two parameter packs. Swift 6.4.2 cannot unify a result type such as `Tuple<repeat each Left, repeat each Right>` with a concrete `Tuple` type, even within one module, so results of the two-pack form could not be annotated, compared, or passed to a typed parameter. A result that joins one pack with fixed members, `Tuple<repeat each Left, Right0, Right1>`, unifies correctly.

## Consequences

The right operand is limited to six members; `Scripts/generate-concatenation.py` raises the limit. A chain of four or more `+` operands in one expression still fails to type-check, so callers split it into steps. When a toolchain fixes the two-pack bug, the fixture in `Tests/KnownCompilerBugs` stops failing, and the overloads can collapse back into one.
