/// Reflects the members the way a built-in tuple reflects.
///
/// ```swift
/// dump(Tuple(1, "a"))
/// // ▿ (2 elements)
/// //   - .0: 1
/// //   - .1: "a"
/// ```
extension Tuple: CustomReflectable {
  /// A mirror with one child per member, labeled `.0`, `.1`, and so on, in the tuple
  /// display style.
  public var customMirror: Mirror {
    let children = erasedMembers.enumerated()
      .map { position, member in
        (label: Optional(".\(position)"), value: member)
      }
    return Mirror(self, children: children, displayStyle: .tuple)
  }
}
