import Testing
import TupleKit
import TupleKitComposition

private struct Request<Response> {
  var path: String
}

private struct Account {
  let id: Int
}

private struct Preferences {
  let assetIDs: [Int]
  let lastSessionID: Int
}

private struct Asset {}
private struct LastSession {}

private typealias RequestPlan = Tuple<
  Request<Account>, Request<Preferences>, Tuple<Request<[Asset]>, Request<LastSession>>
>

private func makePlan() -> RequestPlan {
  Tuple(
    Request<Account>(path: "/accounts/42"),
    Request<Preferences>(path: "/accounts/"),
    Tuple(
      Request<[Asset]>(path: "/assets/"),
      Request<LastSession>(path: "/sessions/")
    )
  )
}

struct FunctionCompositionTests {
  @Test func typedSubscriptBuildsTheDependentPreferencesRequest() {
    let plan = makePlan()
    let toPreferences: (Account) -> Request<Preferences> =
      plan[
        \.1,
        map: { template in
          { account in
            var request = template
            request.path += "\(account.id)/preferences"
            return request
          }
        }
      ]
    let addRevision: (Request<Preferences>) -> Request<Preferences> = { request in
      var copy = request
      copy.path += "?revision=1"
      return copy
    }

    let next: Request<Preferences> = Account(id: 42) |> toPreferences >>> addRevision

    #expect(next.path == "/accounts/42/preferences?revision=1")
    #expect(plan.1.path == "/accounts/")
  }

  @Test func typedSubscriptBuildsTheParallelFinalRequests() {
    let plan = makePlan()
    let preferences = Preferences(assetIDs: [7, 8], lastSessionID: 9)
    let finalTemplates = plan[\.2]

    let parallel: Tuple<Request<[Asset]>, Request<LastSession>> =
      Tuple(preferences, finalTemplates)[
        \.0,
        \.1,
        map: { response, templates in
          let assetIDs = response.assetIDs.map(String.init).joined(separator: ",")
          return Tuple(
            Request<[Asset]>(path: templates.0.path + assetIDs),
            Request<LastSession>(path: templates.1.path + "\(response.lastSessionID)")
          )
        }
      ]

    #expect(parallel.0.path == "/assets/7,8")
    #expect(parallel.1.path == "/sessions/9")
    #expect(plan[\.2][\.0].path == "/assets/")
    #expect(plan[\.2][\.1].path == "/sessions/")
  }

  @Test func mappingSubscriptPreservesOptionalNilAndSelectionOrder() {
    let box = Tuple(nil as Int?, "ready")
    var calls = 0

    let result = box[
      \.1,
      \.0,
      map: { text, number in
        calls += 1
        return "\(text):\(number.map(String.init) ?? "none")"
      }
    ]

    #expect(result == "ready:none")
    #expect(calls == 1)
    #expect(box.0 == nil)
  }

  @Test func forwardCompositionRunsEachFunctionOnceInOrder() {
    var calls: [String] = []
    let increment: (Int) -> Int = { value in
      calls.append("increment")
      return value + 1
    }
    let label: (Int) -> String = { value in
      calls.append("label")
      return "value=\(value)"
    }

    let result: String = 3 |> increment >>> label

    #expect(result == "value=4")
    #expect(calls == ["increment", "label"])
  }
}
