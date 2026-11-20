import Testing
import TupleKit

struct MirrorTests {
  @Test func reflectsMembersAsPositionLabeledTupleChildren() {
    let mirror = Mirror(reflecting: Tuple(1, "ready", nil as Int?))

    #expect(mirror.displayStyle == .tuple)
    #expect(mirror.children.map(\.label) == [".0", ".1", ".2"])
    #expect(mirror.children.map { String(describing: $0.value) } == ["1", "ready", "nil"])
  }

  @Test func dumpMatchesABuiltInTupleWithTheSameMembers() {
    var reflected = ""
    var builtIn = ""

    dump(Tuple(1, "ready", [true]), to: &reflected)
    dump((1, "ready", [true]), to: &builtIn)

    #expect(reflected == builtIn)
  }

  @Test func emptyTupleHasNoChildren() {
    #expect(Mirror(reflecting: Tuple()).children.isEmpty)
  }
}
