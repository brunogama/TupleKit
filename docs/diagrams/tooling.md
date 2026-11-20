# Repository tooling functions

Diagrams show containment of named functions in repository-owned Python and Bash scripts, not execution order. Python declarations come from `ast`. Bash diagrams include named `name() {` declarations.

---

## check-compiler-contracts.sh

[`Scripts/check-compiler-contracts.sh`](../../Scripts/check-compiler-contracts.sh)

```mermaid
flowchart LR
  n0["check-compiler-contracts.sh"]
```

---

## check-coverage.py

[`Scripts/check-coverage.py`](../../Scripts/check-coverage.py)

```mermaid
flowchart LR
  n0["check-coverage.py"]
  n1["codecov_path :24"]
  n2["library_files :35"]
  n3["main :39"]
  n0 --> n1
  n0 --> n2
  n0 --> n3
```

---

## check-doc-snippets.py

[`Scripts/check-doc-snippets.py`](../../Scripts/check-doc-snippets.py)

```mermaid
flowchart LR
  n0["check-doc-snippets.py"]
  n1["text_lines :56"]
  n2["blocks :63"]
  n3["wrap :85"]
  n4["build_consumer :113"]
  n5["main :148"]
  n0 --> n4
  n0 --> n5
  n0 --> n1
  n0 --> n2
  n0 --> n3
```

---

## check-golden-snapshots.py

[`Scripts/check-golden-snapshots.py`](../../Scripts/check-golden-snapshots.py)

```mermaid
flowchart LR
  n0["check-golden-snapshots.py"]
  n1["read_contracts :16"]
  n2["fixture_problems :32"]
  n3["test_problems :52"]
  n4["main :59"]
  n0 --> n1
  n0 --> n2
  n0 --> n3
  n0 --> n4
```

---

## conventional-commits.py

[`Scripts/conventional-commits.py`](../../Scripts/conventional-commits.py)

```mermaid
flowchart LR
  n0["conventional-commits.py"]
  n1["git :35"]
  n2["commits :39"]
  n3["problem :48"]
  n4["message_from_file :61"]
  n5["lint :68"]
  n6["breaking_footers :85"]
  n7["parse :99"]
  n8["latest_tag :111"]
  n9["next_version :116"]
  n10["notes :130"]
  n11["entry :137"]
  n12["write_changelog :151"]
  n13["release :158"]
  n14["main :188"]
  n0 --> n8
  n0 --> n9
  n0 --> n10
  n0 --> n11
  n0 --> n12
  n0 --> n13
  n0 --> n14
  n0 --> n1
  n0 --> n2
  n0 --> n3
  n0 --> n4
  n0 --> n5
  n0 --> n6
  n0 --> n7
```

---

## generate-concatenation.py

[`Scripts/generate-concatenation.py`](../../Scripts/generate-concatenation.py)

```mermaid
flowchart LR
  n0["generate-concatenation.py"]
  n1["construction :18"]
  n0 --> n1
```

---

## swift-style

[`Scripts/swift-style`](../../Scripts/swift-style)

```mermaid
flowchart LR
  n0["swift-style"]
  n1["fail :6"]
  n2["usage :11"]
  n3["lint_files :179"]
  n0 --> n2
  n0 --> n3
  n0 --> n1
```

---

## swift-style-analyze

[`Scripts/swift-style-analyze`](../../Scripts/swift-style-analyze)

```mermaid
flowchart LR
  n0["swift-style-analyze"]
```

---

## test_check_golden_snapshots.py

[`Scripts/test_check_golden_snapshots.py`](../../Scripts/test_check_golden_snapshots.py)

```mermaid
flowchart LR
  n0["test_check_golden_snapshots.py"]
  n1["setUp :18"]
  n2["git :57"]
  n3["run_checker :60"]
  n4["test_accepts_required_fixture_and_discovered_test_in_read_only_mode :75"]
  n5["test_rejects_missing_required_test_even_when_fixture_exists :79"]
  n6["test_rejects_an_untracked_fixture :85"]
  n7["test_rejects_a_missing_fixture :91"]
  n8["test_rejects_a_fixture_staged_but_not_in_the_pushed_commit :97"]
  n9["test_propagates_snapshot_test_failure :106"]
  n0 --> n9
  n0 --> n1
  n0 --> n2
  n0 --> n3
  n0 --> n4
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
```

---

## test_conventional_commits.py

[`Scripts/test_conventional_commits.py`](../../Scripts/test_conventional_commits.py)

```mermaid
flowchart LR
  n0["test_conventional_commits.py"]
  n1["__init__ :13"]
  n2["git :21"]
  n3["commit :24"]
  n4["run :28"]
  n5["setUp :36"]
  n6["tearDown :42"]
  n7["release :45"]
  n8["test_lint_accepts_conventional_subjects :51"]
  n9["test_lint_rejects_nonconforming_messages :55"]
  n10["test_lint_reads_a_commit_message_file_like_git_records_it :59"]
  n11["test_lint_checks_every_commit_in_a_range_and_skips_merges :67"]
  n12["test_fix_bumps_patch :81"]
  n13["test_feat_bumps_minor_and_resets_patch :85"]
  n14["test_breaking_change_bumps_major :90"]
  n15["test_wrapped_breaking_footer_keeps_every_line :95"]
  n16["test_bang_bumps_major :101"]
  n17["test_release_as_sets_the_version :105"]
  n18["test_release_as_must_be_greater_than_the_last_tag :109"]
  n19["test_only_docs_and_chores_release_nothing :113"]
  n20["test_changelog_lists_sections_and_prepends_new_releases :119"]
  n0 --> n16
  n0 --> n17
  n0 --> n18
  n0 --> n19
  n0 --> n20
  n0 --> n1
  n0 --> n2
  n0 --> n3
  n0 --> n4
  n0 --> n5
  n0 --> n6
  n0 --> n7
  n0 --> n8
  n0 --> n9
  n0 --> n10
  n0 --> n11
  n0 --> n12
  n0 --> n13
  n0 --> n14
  n0 --> n15
```
