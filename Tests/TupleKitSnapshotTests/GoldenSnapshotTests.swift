import Foundation
import SnapshotTesting
import Testing
import TupleKit

private enum Size: String, CaseIterable, Codable {
  case small
  case large
}

private enum Tone: String, CaseIterable, Codable {
  case light
  case dark
}

/// One rendered line per sample, so a change to any textual surface shows up as a diff
/// against the recorded golden master.
private struct Sample {
  let name: String
  let description: String
  let debugDescription: String
  let streamed: String

  init<each Member>(_ name: String, _ tuple: Tuple<repeat each Member>) {
    self.name = name
    description = tuple.description
    debugDescription = tuple.debugDescription
    var streamed = ""
    tuple.write(to: &streamed)
    self.streamed = streamed
  }

  var report: String {
    """
    ## \(name)
    description:      \(description)
    debugDescription: \(debugDescription)
    streamed:         \(streamed)
    """
  }
}

private let samples = [
  Sample("empty", Tuple()),
  Sample("single", Tuple(42)),
  Sample("mixed", Tuple(42, "ready", true, 2.5)),
  Sample("optional members", Tuple(1 as Int?, nil as String?)),
  Sample("nested", Tuple(1, Tuple("a", Tuple(true)))),
  Sample("collections", Tuple([1, 2], ["key": "value"], Set<Int>())),
  Sample("enums", Tuple(Size.large, Tone.dark)),
]

/// Golden master tests: each recorded snapshot is the approved output, and any change to a
/// rendering fails until it is reviewed and re-recorded.
///
/// The trait sets no record mode, so `SNAPSHOT_TESTING_RECORD` decides it. CI sets `never`.
@Suite(.snapshots)
struct GoldenSnapshotTests {
  @Test func textualRepresentations() {
    let report = samples.map(\.report).joined(separator: "\n\n")
    assertSnapshot(of: report, as: .lines)
  }

  /// Pins the output of the standard library's `dump`, which reads ``Tuple/customMirror``.
  @Test func mirrorDump() {
    var output = ""
    dump(Tuple(42, "ready", nil as Double?, Tuple(true, [1, 2])), to: &output)
    assertSnapshot(of: output, as: .lines)
  }

  @Test func jsonEncoding() {
    let tuple = Tuple(
      42,
      "ready",
      nil as Double?,
      [true, false],
      Size.large,
      Tuple("nested", 1)
    )
    assertSnapshot(of: tuple, as: .json)
  }

  @Test func caseIterableOrder() {
    let cases = Tuple<Size, Tone, Size>.allCases
      .map { $0.description }
      .joined(separator: "\n")
    assertSnapshot(of: cases, as: .lines)
  }

  @Test func rawValues() {
    let raw = Tuple(Size.small, Tone.dark).rawValues
    let lifted = Tuple<Size, Tone>(rawValues: Tuple("large", "light"))
    let missing = Tuple<Size, Tone>(rawValues: Tuple("medium", "light"))
    let report = """
      rawValues:          \(raw.debugDescription)
      init(rawValues:):   \(String(describing: lifted))
      unknown raw value:  \(String(describing: missing))
      """
    assertSnapshot(of: report, as: .lines)
  }

  @Test func elementwiseArithmetic() {
    let steps = [Tuple(1, 0.5), Tuple(2, 0.25), Tuple(3, 0.25)]
    let total = steps.map(ElementwiseTuple.init).reduce(.zero, +).tuple
    let difference = (Tuple(5, 2.5).elementwise - Tuple(2, 0.5).elementwise).tuple
    let report = """
      sum:         \(total.debugDescription)
      difference:  \(difference.debugDescription)
      zero:        \(ElementwiseTuple<Int, Double>.zero.tuple.debugDescription)
      """
    assertSnapshot(of: report, as: .lines)
  }

  @Test func concatenation() {
    let pair = Tuple(1, 2.5)
    let samePair = pair + pair
    let mixed = pair + Tuple("a", true)
    let report = """
      same type:   \(samePair.debugDescription)
      mixed type:  \(mixed.debugDescription)
      """
    assertSnapshot(of: report, as: .lines)
  }
}
