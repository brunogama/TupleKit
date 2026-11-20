#!/usr/bin/env python3
"""Compiles every Swift code block in the DocC catalog, the README, and the `///` doc
comments under Sources as a client module.

A block runs inside an async throwing function after a shared prelude. Top-level type and
function declarations in a block are hoisted to file scope. Mark a block with
`<!-- snippet: standalone -->` to compile it exactly as written, `<!-- snippet: continues -->`
to append it to the previous block of the same document, or `<!-- snippet: skip -->` to
exclude code that is meant not to compile, such as code from before a migration. A block's
own imports go at the top of the file. Blocks that import SwiftUI are skipped off macOS.
Pass --run to also execute each wrapped block.
"""
import json
import pathlib
import re
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
DOCUMENTS = (
    sorted((ROOT / 'Sources/TupleKit/TupleKit.docc').glob('*.md'))
    + [ROOT / 'README.md']
    + sorted((ROOT / 'Sources').rglob('*.swift'))
)
DOC_COMMENT = re.compile(r'^\s*/// ?(.*)$')
DECLARATION = re.compile(
    r'^(actor|struct|final class|class|enum|protocol|extension|func|typealias|@propertyWrapper|@MainActor|@Observable)\b'
)

PRELUDE = '''import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import TupleKit
import TupleKitComposition

struct Request<Response: Decodable & Sendable>: Sendable {
    let path: String
}
struct Asset: Codable, Sendable { let id: Int }
struct LastSession: Codable, Sendable { let id: Int }
struct Dispatcher: Sendable {
    func send<Response: Decodable & Sendable>(_ request: Request<Response>) async throws -> Response {
        switch Response.self {
        case is [Asset].Type: return [Asset(id: 7)] as! Response
        case is LastSession.Type: return LastSession(id: 3) as! Response
        default: throw CancellationError()
        }
    }
}
let dispatcher = Dispatcher()
'''


def text_lines(document):
    lines = document.read_text().split('\n')
    if document.suffix != '.swift':
        return lines
    return [match.group(1) if (match := DOC_COMMENT.match(line)) else '' for line in lines]


def blocks(document):
    lines = text_lines(document)
    marker = None
    index = 0
    while index < len(lines):
        line = lines[index]
        match = re.fullmatch(r'<!-- snippet: (standalone|skip|continues) -->', line.strip())
        if match:
            marker = match.group(1)
        elif line.strip() == '```swift':
            start = index + 1
            end = start
            while lines[end].strip() != '```':
                end += 1
            yield start + 1, marker, '\n'.join(lines[start:end])
            marker = None
            index = end
        elif line.strip():
            marker = None
        index += 1


def wrap(code):
    declarations, statements, imports = [], [], []
    lines = code.split('\n')
    index = 0
    while index < len(lines):
        line = lines[index]
        if DECLARATION.match(line) or line.startswith('import '):
            chunk = [line]
            if '{' in line and not line.rstrip().endswith('}'):
                index += 1
                while not lines[index].startswith('}'):
                    chunk.append(lines[index])
                    index += 1
                chunk.append(lines[index])
            if line.startswith('import '):
                imports.append(line)
            else:
                declarations.extend(chunk)
        else:
            statements.append('    ' + line if line else line)
        index += 1
    return '\n'.join(
        [*imports, PRELUDE, *declarations, '', '@main', 'enum Snippet {', '    static func main() async throws {']
        + ['    ' + line if line else line for line in statements]
        + ['    }', '}', '']
    )


def build_consumer(scratch, snippets):
    """Builds (label, Swift source, executable) entries using public package products."""
    targets = []
    for index, (_, code, executable) in enumerate(snippets):
        name = f'Snippet{index}'
        directory = scratch / 'Sources' / name
        directory.mkdir(parents=True)
        (directory / 'Snippet.swift').write_text(code)
        kind = 'executableTarget' if executable else 'target'
        targets.append(f'.{kind}(name: "{name}", dependencies: ['
                       '.product(name: "TupleKit", package: "TupleKit"), '
                       '.product(name: "TupleKitComposition", package: "TupleKit")])')
    manifest = '''// swift-tools-version: 6.4.2
import PackageDescription
let package = Package(
  name: "DocumentationConsumer",
  platforms: [.macOS(.v14), .iOS(.v17)],
  dependencies: [.package(name: "TupleKit", path: ROOT_PATH)],
  targets: [TARGETS],
  swiftLanguageModes: [.v6]
)
'''.replace('ROOT_PATH', json.dumps(str(ROOT))).replace('TARGETS', ',\n    '.join(targets))
    (scratch / 'Package.swift').write_text(manifest)
    result = subprocess.run(['swift', 'build', '--package-path', str(scratch)],
                            capture_output=True, text=True)
    if result.returncode:
        for index, (label, _, _) in enumerate(snippets):
            print(f'Snippet{index}: {label}')
        raise RuntimeError(result.stdout + result.stderr)
    return pathlib.Path(subprocess.run(
        ['swift', 'build', '--package-path', str(scratch), '--show-bin-path'],
        check=True, capture_output=True, text=True
    ).stdout.strip())


def main():
    run = '--run' in sys.argv
    snippets = []
    for document in DOCUMENTS:
        previous = ''
        for line_number, marker, code in blocks(document):
            if marker == 'skip':
                continue
            if marker == 'continues':
                code = previous + '\n' + code
            previous = code
            label = f'{document.relative_to(ROOT)}:{line_number}'
            if 'import SwiftUI' in code and sys.platform != 'darwin':
                print(f'skip {label} (SwiftUI)')
                continue
            snippets.append((label, code if marker == 'standalone' else wrap(code),
                             marker != 'standalone'))
    failures = 0
    with tempfile.TemporaryDirectory() as scratch:
        try:
            bin_path = build_consumer(pathlib.Path(scratch), snippets)
        except RuntimeError as error:
            print(f'FAIL documentation consumer build\n{error}')
            return 1
        for index, (label, _, executable) in enumerate(snippets):
            if run and executable:
                executed = subprocess.run([str(bin_path / f'Snippet{index}')],
                                          capture_output=True, text=True, timeout=60)
                if executed.returncode:
                    failures += 1
                    print(f'FAIL {label}: exited with {executed.returncode}\n{executed.stderr[-500:]}')
                    continue
                print(f'ok   {label}\n' + '\n'.join(
                    '     | ' + line for line in executed.stdout.strip().split('\n')))
            else:
                print(f'ok   {label}')
    print(f'{len(snippets) - failures} of {len(snippets)} snippets compiled')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
