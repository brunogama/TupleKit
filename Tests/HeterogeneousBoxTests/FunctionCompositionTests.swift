import HeterogeneousBox
import XCTest

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

final class FunctionCompositionTests: XCTestCase {
    func testTypedSubscriptsBuildDependentRequestStages() {
        let plan = HeterogeneousBox(
            Request<Account>(path: "/accounts/42"),
            Request<Preferences>(path: "/accounts/"),
            HeterogeneousBox(
                Request<[Asset]>(path: "/assets/"),
                Request<LastSession>(path: "/sessions/")
            )
        )

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
        XCTAssertEqual(next.path, "/accounts/42/preferences?revision=1")
        XCTAssertEqual(plan.1.path, "/accounts/")

        let preferences = Preferences(assetIDs: [7, 8], lastSessionID: 9)
        let parallel: HeterogeneousBox<Request<[Asset]>, Request<LastSession>> =
            HeterogeneousBox(preferences, plan.value.2)[
                \.0,
                \.1,
                map: { response, templates in
                    HeterogeneousBox(
                        Request<[Asset]>(
                            path: templates.0.path + response.assetIDs.map(String.init).joined(separator: ",")
                        ),
                        Request<LastSession>(path: templates.1.path + "\(response.lastSessionID)")
                    )
                }
            ]

        XCTAssertEqual(parallel.0.path, "/assets/7,8")
        XCTAssertEqual(parallel.1.path, "/sessions/9")
        XCTAssertEqual(plan.value.2.0.path, "/assets/")
        XCTAssertEqual(plan.value.2.1.path, "/sessions/")
    }

    func testMappingSubscriptPreservesOptionalNilAndSelectionOrder() {
        let box = HeterogeneousBox(nil as Int?, "ready")
        var calls = 0

        let result = box[
            \.1,
            \.0,
            map: { text, number in
                calls += 1
                return "\(text):\(number.map(String.init) ?? "none")"
            }
        ]

        XCTAssertEqual(result, "ready:none")
        XCTAssertEqual(calls, 1)
        XCTAssertNil(box.0)
    }

    func testForwardCompositionRunsEachFunctionOnceInOrder() {
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

        XCTAssertEqual(result, "value=4")
        XCTAssertEqual(calls, ["increment", "label"])
    }
}
