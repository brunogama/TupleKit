import Testing

@testable import TupleKit  // Import the module being tested

struct TupleKitTests {

  // MARK: - Initialization Tests

  @Test func initializationWithVariadicArguments() {
    let box1 = Tuple(1, "hello", true, 3.14)
    #expect(box1.count == 4)
    #expect(box1.erasedMembers[0] as? Int == 1)
    #expect(box1.erasedMembers[1] as? String == "hello")
    #expect(box1.erasedMembers[2] as? Bool == true)
    #expect(box1.erasedMembers[3] as? Double == 3.14)

    let boxEmpty = Tuple()  // Test empty init
    #expect(boxEmpty.isEmpty)
    #expect([Tuple().count, Tuple(1).count, Tuple(1, "a").count] == [0, 1, 2])
  }

  @Test func writeableKeyPathSubscript() {
    var boxCopy = Tuple(1, "test")
    boxCopy.0 = 2
    boxCopy.1 = "changed"

    #expect(boxCopy.0 == 2)
    #expect(boxCopy.1 == "changed")
  }

  // MARK: - Count and IsEmpty Tests

  @Test func countAndIsEmpty() {
    let box = Tuple(1, "test")
    #expect(box.count == 2)
    #expect(!box.isEmpty)

    let boxEmpty = Tuple()
    #expect(boxEmpty.isEmpty)
    #expect(!Tuple(1).isEmpty)
  }

  // MARK: - Element Access Tests (Index-Based)

  @Test func getElementByWriteableKeyPathSubscript() {
    let box = Tuple(10, false, "world")
    #expect(box.0 == 10)
    #expect(box.1 == false)
    #expect(box.2 == "world")
    #expect(2 < box.count)  // Precondition check
  }

  // MARK: - Computed Property Tests

  @Test func erasedMembersCopiesMembersInPositionOrder() {
    let box = Tuple(70, "array", true)
    let array = box.erasedMembers
    #expect(array.count == 3)
    #expect(array[0] as? Int == 70)
    #expect(array[1] as? String == "array")
    #expect(array[2] as? Bool == true)

    let boxEmpty = Tuple()
    #expect(boxEmpty.erasedMembers.isEmpty)
  }

  // MARK: - Method Tests

  @Test func descriptionKeepsStringMembersDistinct() {
    #expect(Tuple("a, b").description == #"Tuple("a, b")"#)
    #expect(Tuple("a", "b").description == #"Tuple("a", "b")"#)
    #expect(Tuple("", 1).description == #"Tuple("", 1)"#)
  }

  @Test func descriptionQuotesOnlyTextMembers() {
    let tuple = Tuple(Character("c"), "line\nbreak"[...], ["k": "v"], 1 as Int?, 2.5)

    #expect(tuple.description == #"Tuple("c", "line\nbreak", ["k": "v"], Optional(1), 2.5)"#)
  }

  @Test func descriptionRendersPrivateTypesWithoutAddresses() {
    enum Phase { case ready }

    #expect(Tuple(Phase.ready, 1).description == "Tuple(ready, 1)")
  }

  @Test func nestedTuplesRenderInTheirPlainForm() {
    let nested = Tuple(1, Tuple("a", Tuple(true)))

    #expect(nested.description == #"Tuple(1, Tuple("a", Tuple(true)))"#)
    let nestedType = "Tuple<String, Tuple<Bool>>"
    #expect(
      nested.debugDescription
        == #"Tuple<Int, \#(nestedType)> { 1 (Int), Tuple("a", Tuple(true)) (\#(nestedType)) }"#
    )
  }

  @Test func descriptionsNameStaticMemberTypes() {
    let tuple = Tuple(1, nil as String?, true)

    #expect(tuple.description == "Tuple(1, nil, true)")
    #expect(
      tuple.debugDescription
        == "Tuple<Int, Optional<String>, Bool> "
        + "{ 1 (Int), nil (Optional<String>), true (Bool) }"
    )
  }

  @Test func equality() {
    let box1 = Tuple(1, "test")
    let box2 = Tuple(1, "test")
    let box3 = Tuple(2, "test")

    #expect(box1 == box2)
    #expect(box1 != box3)
    #expect(box2 != box3)
  }

}
