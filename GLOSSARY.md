# TupleKit

A library for fixed-shape product values whose members keep their own static types.

## Language

**Tuple**:
The library's fixed-shape product value: an ordered group of members, each with its own static type.
_Avoid_: Box, heterogeneous box, collection, container, list

**Built-in tuple**:
Swift's language tuple, such as `(Int, String)`, which a Tuple stores its members in.
_Avoid_: Raw tuple, plain tuple

**Member**:
One value held in a Tuple at a fixed position, with its own static type.
_Avoid_: Element, value, item

**Members**:
All of a Tuple's members taken together, in position order.
_Avoid_: Value, contents

**Position**:
The zero-based place of a member within its Tuple.
_Avoid_: Index, offset

**Shape**:
The ordered list of a Tuple's member types. Two Tuples with different shapes are different types.
_Avoid_: Layout, signature, type pack

**Erased members**:
A Tuple's members copied into an array of `Any`, which drops their static types.
_Avoid_: Array, values, elements
