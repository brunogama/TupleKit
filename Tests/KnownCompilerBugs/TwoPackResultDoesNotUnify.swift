import TupleKit

func join<each Left, each Right>(
  _ lhs: Tuple<repeat each Left>,
  _ rhs: Tuple<repeat each Right>
) -> Tuple<repeat each Left, repeat each Right> {
  Tuple<repeat each Left, repeat each Right>(
    members: (repeat each lhs.members, repeat each rhs.members)
  )
}

func useJoinedType() {
  let joined: Tuple<Int, String> = join(Tuple(1), Tuple("a"))  // known-bug
  print(joined)
}
