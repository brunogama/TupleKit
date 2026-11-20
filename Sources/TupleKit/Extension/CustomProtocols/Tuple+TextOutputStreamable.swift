/// Writes the members straight into a text stream, in the same form as `description`.
///
/// ```swift
/// var log = ""
/// Tuple(1, "a").write(to: &log)
/// // log is #"Tuple(1, "a")"#
/// ```
extension Tuple: TextOutputStreamable {
  /// Writes the members, in position order, as `Tuple(1, "a")`.
  ///
  /// - Parameter target: The stream to write into.
  public func write<Target: TextOutputStream>(to target: inout Target) {
    target.write("Tuple(")
    var position = 0
    for member in repeat each members {
      if position > 0 { target.write(", ") }
      renderMember(member, into: &target)
      position += 1
    }
    target.write(")")
  }
}
