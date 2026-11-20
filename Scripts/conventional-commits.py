#!/usr/bin/env python3
"""Checks Conventional Commits and computes semantic-version releases from them.

  lint RANGE           Fail when a non-merge commit in RANGE breaks the convention.
  lint --message TEXT  Check one message, such as a pull request title.
  lint --file PATH     Check a commit message file, as a commit-msg hook receives it.
  release              Compute the next version from the commits since the last vX.Y.Z tag.

A commit subject must read `type(scope)!: description`, where the scope and `!` are optional.
`feat` bumps the minor version, `fix` and `perf` bump the patch version, and `!` or a
`BREAKING CHANGE:` footer bumps the major version. A `Release-As: X.Y.Z` footer sets the
version explicitly. Other types appear in no release on their own.
"""
import argparse
import datetime
import os
import pathlib
import re
import subprocess
import sys

TYPES = ('feat', 'fix', 'perf', 'refactor', 'docs', 'style', 'test', 'build', 'ci', 'chore', 'revert')
SUBJECT = re.compile(
    r'^(?P<type>' + '|'.join(TYPES) + r')(?:\((?P<scope>[\w./-]+)\))?(?P<breaking>!)?: (?P<description>\S.*)$'
)
BREAKING_FOOTER = re.compile(r'^BREAKING[ -]CHANGE: ')
FOOTER_TOKEN = re.compile(r'^(BREAKING[ -]CHANGE|[\w-]+): ')
RELEASE_AS = re.compile(r'^Release-As: v?(?P<version>\d+\.\d+\.\d+)\s*$', re.MULTILINE)
TAG = re.compile(r'^v(\d+)\.(\d+)\.(\d+)$')
SECTIONS = (('feat', 'Features'), ('fix', 'Bug Fixes'), ('perf', 'Performance Improvements'))
SEPARATOR = '\x1f'
RECORD_END = '\x1e'


def git(*arguments):
    return subprocess.run(['git', *arguments], check=True, capture_output=True, text=True).stdout


def commits(revision_range):
    output = git('log', '--no-merges', '--reverse', f'--format=%H{SEPARATOR}%B{RECORD_END}', revision_range)
    for record in output.split(RECORD_END):
        record = record.strip('\n')
        if record:
            sha, message = record.split(SEPARATOR, 1)
            yield sha, message.strip()


def problem(message):
    subject = message.split('\n', 1)[0]
    if not SUBJECT.match(subject):
        return f'subject must read "type(scope)!: description" with a type from {", ".join(TYPES)}'
    lines = message.split('\n')
    if len(lines) > 1 and lines[1].strip():
        return 'leave a blank line between the subject and the body'
    for match in RELEASE_AS.finditer(message):
        if not TAG.match('v' + match.group('version')):
            return 'Release-As must be a version such as 6.0.0'
    return None


def message_from_file(path):
    """Returns the message that git will record, without comment lines or the diff below the scissors."""
    text = pathlib.Path(path).read_text()
    text = text.split('# ------------------------ >8 ------------------------', 1)[0]
    return '\n'.join(line for line in text.splitlines() if not line.startswith('#')).strip()


def lint(arguments):
    if arguments.file is not None:
        messages = [('message', message_from_file(arguments.file))]
    elif arguments.message is not None:
        messages = [('message', arguments.message)]
    else:
        messages = [(sha[:7], message) for sha, message in commits(arguments.range)]
    failures = [(name, message, problem(message)) for name, message in messages if problem(message)]
    for name, message, reason in failures:
        print(f'::error::{name} "{message.splitlines()[0]}": {reason}')
    if failures:
        print('See https://www.conventionalcommits.org/en/v1.0.0/')
        return 1
    print('All messages follow Conventional Commits.')
    return 0


def breaking_footers(body):
    """Returns each BREAKING CHANGE footer, joining its wrapped lines until a blank line or the next footer."""
    footers, current = [], None
    for line in body.split('\n'):
        if BREAKING_FOOTER.match(line):
            current = [BREAKING_FOOTER.sub('', line).strip()]
            footers.append(current)
        elif current is not None and line.strip() and not FOOTER_TOKEN.match(line):
            current.append(line.strip())
        else:
            current = None
    return [' '.join(parts) for parts in footers]


def parse(message):
    subject, _, body = message.partition('\n')
    match = SUBJECT.match(subject)
    if not match:
        return None
    breaking = breaking_footers(body)
    if match.group('breaking') and not breaking:
        breaking = [match.group('description')]
    release_as = [footer.group('version') for footer in RELEASE_AS.finditer(body)]
    return {**match.groupdict(), 'breaking': breaking, 'release_as': release_as}


def latest_tag():
    tags = [tag for tag in git('tag', '--merged', 'HEAD').split() if TAG.match(tag)]
    return max(tags, key=lambda tag: tuple(int(part) for part in TAG.match(tag).groups()), default=None)


def next_version(current, changes):
    major, minor, patch = current
    explicit = [tuple(int(part) for part in version.split('.')) for change in changes for version in change['release_as']]
    if explicit:
        return max(explicit)
    if any(change['breaking'] for change in changes):
        return (major + 1, 0, 0)
    if any(change['type'] == 'feat' for change in changes):
        return (major, minor + 1, 0)
    if any(change['type'] in ('fix', 'perf') for change in changes):
        return (major, minor, patch + 1)
    return None


def notes(version, previous, changes, repository):
    heading = f'v{version}'
    if repository and previous:
        heading = f'[v{version}](https://github.com/{repository}/compare/{previous}...v{version})'
    date = git('log', '-1', '--format=%cs', 'HEAD').strip() or datetime.date.today().isoformat()
    lines = [f'## {heading} ({date})', '']

    def entry(change, text):
        scope = f"**{change['scope']}:** " if change['scope'] else ''
        return f"- {scope}{text} ({change['sha'][:7]})"

    breaking = [entry(change, text) for change in changes for text in change['breaking']]
    if breaking:
        lines += ['### Breaking Changes', '', *breaking, '']
    for kind, title in SECTIONS:
        entries = [entry(change, change['description']) for change in changes if change['type'] == kind]
        if entries:
            lines += [f'### {title}', '', *entries, '']
    return '\n'.join(lines)


def write_changelog(path, section):
    header = '# Changelog\n\nThis file is generated by Scripts/conventional-commits.py. Do not edit it.\n\n'
    existing = path.read_text() if path.exists() else ''
    body = existing[len(header):] if existing.startswith(header) else existing
    path.write_text(header + section + ('\n' + body if body else ''))


def release(arguments):
    tag = latest_tag()
    current = tuple(int(part) for part in TAG.match(tag).groups()) if tag else (0, 0, 0)
    changes = []
    for sha, message in commits(f'{tag}..HEAD' if tag else 'HEAD'):
        change = parse(message)
        if change:
            changes.append({**change, 'sha': sha})
    version = next_version(current, changes)
    if version and version <= current:
        print(f'::error::Release-As {".".join(map(str, version))} is not greater than {tag}')
        return 1
    outputs = {'released': 'false'}
    if version:
        text = '.'.join(map(str, version))
        section = notes(text, tag, changes, arguments.repository)
        outputs = {'released': 'true', 'version': text, 'tag': f'v{text}'}
        if arguments.changelog:
            write_changelog(pathlib.Path(arguments.changelog), section)
        if arguments.notes:
            pathlib.Path(arguments.notes).write_text(section.split('\n', 2)[2])
        print(section)
    else:
        print(f'No feat, fix, perf, or breaking commits since {tag or "the first commit"}. Nothing to release.')
    if arguments.github_output:
        with open(arguments.github_output, 'a') as handle:
            handle.writelines(f'{key}={value}\n' for key, value in outputs.items())
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest='command', required=True)
    lint_parser = commands.add_parser('lint')
    source = lint_parser.add_mutually_exclusive_group(required=True)
    source.add_argument('range', nargs='?')
    source.add_argument('--message')
    source.add_argument('--file')
    release_parser = commands.add_parser('release')
    release_parser.add_argument('--changelog', help='prepend the release section to this file')
    release_parser.add_argument('--notes', help='write the release notes to this file')
    release_parser.add_argument('--repository', default=os.environ.get('GITHUB_REPOSITORY'))
    release_parser.add_argument('--github-output', default=os.environ.get('GITHUB_OUTPUT'))
    arguments = parser.parse_args()
    return lint(arguments) if arguments.command == 'lint' else release(arguments)


if __name__ == '__main__':
    sys.exit(main())
