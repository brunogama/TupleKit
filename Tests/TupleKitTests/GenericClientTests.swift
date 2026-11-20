import Foundation
import Testing
import TupleKit

private func checkGenericShape<each Member>(
  _ tuple: Tuple<repeat each Member>,
  count: Int,
  description: String
) {
  #expect(tuple.count == count)
  #expect(tuple.isEmpty == (count == 0))
  #expect(tuple.erasedMembers.count == count)
  #expect(tuple.description == description)
  var streamed = ""
  tuple.write(to: &streamed)
  #expect(streamed == description)
  #expect(tuple.debugDescription.hasPrefix("Tuple<"))
}

private func genericEncoding<each Member: Encodable>(
  _ tuple: Tuple<repeat each Member>
) throws -> Data {
  try JSONEncoder().encode(tuple)
}

struct GenericClientTests {
  @Test func genericClientsKeepEmptyUnaryAndMixedShapes() throws {
    checkGenericShape(Tuple(), count: 0, description: "Tuple()")
    checkGenericShape(Tuple(7), count: 1, description: "Tuple(7)")
    checkGenericShape(Tuple(7, "ready", true), count: 3, description: #"Tuple(7, "ready", true)"#)
    let encoded = try genericEncoding(Tuple(7, "ready", true))
    #expect(String(bytes: encoded, encoding: .utf8) == #"[7,"ready",true]"#)
  }

  @Test func genericEncodingPropagatesMemberErrors() {
    #expect(throws: EncodingError.self) {
      try genericEncoding(Tuple(7, Double.nan))
    }
  }
}
