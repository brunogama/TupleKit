/// Converts between a tuple and the tuple of its members' raw values.
///
/// These are named members rather than a `RawRepresentable` conformance on purpose. On
/// Swift 6.4.2 a conditional `RawRepresentable` conformance on `Tuple` makes the type
/// checker reject nested literals such as `Tuple(1, Tuple(2, "a"))` as a return value.
/// `Tests/KnownCompilerBugs` keeps a fixture that fails when a toolchain fixes it.
///
/// ```swift
/// enum Size: String { case small, large }
/// enum Tone: String { case light, dark }
/// let raw = Tuple(Size.large, Tone.dark).rawValues
/// // raw is Tuple("large", "dark")
/// let lifted = Tuple<Size, Tone>(rawValues: Tuple("small", "light"))
/// // lifted is Tuple(Size.small, Tone.light)
/// let missing = Tuple<Size, Tone>(rawValues: Tuple("medium", "light"))
/// // missing is nil
/// ```
extension Tuple where repeat each Member: RawRepresentable {
  /// The members' raw values, in position order.
  public var rawValues: Tuple<repeat (each Member).RawValue> {
    Tuple<repeat (each Member).RawValue>(members: (repeat (each members).rawValue))
  }

  /// Creates a tuple from the raw value of every member.
  ///
  /// - Parameter rawValues: One raw value per member, in position order.
  /// - Returns: `nil` when any member has no case for its raw value.
  public init?(rawValues: Tuple<repeat (each Member).RawValue>) {
    func lift<Lifted: RawRepresentable>(_ raw: Lifted.RawValue) throws(NoCase) -> Lifted {
      guard let lifted = Lifted(rawValue: raw) else { throw NoCase() }
      return lifted
    }
    do {
      self.init(members: (repeat try lift(each rawValues.members)))
    }
    catch {
      return nil
    }
  }
}

/// Signals that a raw value matched no case while lifting a tuple.
private struct NoCase: Error {}
