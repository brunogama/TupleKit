/// Encodes the members in position order as an unkeyed container.
///
/// ```swift
/// let data = try JSONEncoder().encode(Tuple(1, "a"))
/// let json = String(bytes: data, encoding: .utf8)  // #"[1,"a"]"#
/// ```
extension Tuple: Encodable where repeat each Member: Encodable {
  /// Encodes every member, in position order, into an unkeyed container.
  ///
  /// - Parameter encoder: The encoder to write to.
  /// - Throws: Any error the encoder throws while encoding a member.
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.unkeyedContainer()
    for member in repeat each members {
      try container.encode(member)
    }
  }
}

/// Decodes one value per member, in position order, from an unkeyed container.
///
/// Decoding fails when the container holds fewer or more values than the tuple has members.
///
/// ```swift
/// let data = Data(#"[1,"a"]"#.utf8)
/// let pair = try JSONDecoder().decode(Tuple<Int, String>.self, from: data)
/// // pair is Tuple(1, "a")
/// ```
extension Tuple: Decodable where repeat each Member: Decodable {
  /// Decodes one value per member, in position order, from an unkeyed container.
  ///
  /// - Parameter decoder: The decoder to read from.
  /// - Throws: `DecodingError.valueNotFound` when the container has too few values,
  ///   `DecodingError.dataCorrupted` when it has too many, and
  ///   `DecodingError.typeMismatch` when a value has the wrong type.
  public init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    func next<Value: Decodable>(_: Value.Type) throws -> Value {
      try container.decode(Value.self)
    }
    // Passing a built-in tuple held in a variable here crashes SIL generation on Swift 6.4.2.
    self.init(members: (repeat try next((each Member).self)))
    guard container.isAtEnd else {
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Expected \(container.currentIndex) values but found more."
        )
      )
    }
  }
}
