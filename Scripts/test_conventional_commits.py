"""Tests Scripts/conventional-commits.py against throwaway git repositories."""
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent / 'conventional-commits.py'


class Repository:
    def __init__(self, directory):
        self.directory = directory
        self.git('init', '-q', '-b', 'main')
        self.git('config', 'user.name', 'Test')
        self.git('config', 'user.email', 'test@example.com')
        self.git('config', 'commit.gpgsign', 'false')
        self.git('config', 'tag.gpgsign', 'false')

    def git(self, *arguments):
        return subprocess.run(['git', *arguments], cwd=self.directory, check=True, capture_output=True, text=True).stdout

    def commit(self, message):
        self.git('commit', '-q', '--allow-empty', '-m', message)
        return self.git('rev-parse', 'HEAD').strip()

    def run(self, *arguments):
        environment = {key: value for key, value in os.environ.items() if not key.startswith('GITHUB_')}
        return subprocess.run(
            [sys.executable, str(SCRIPT), *arguments], cwd=self.directory, capture_output=True, text=True, env=environment
        )


class ConventionalCommitsTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.repo = Repository(self.scratch.name)
        self.repo.commit('chore: start')
        self.repo.git('tag', 'v1.2.3')

    def tearDown(self):
        self.scratch.cleanup()

    def release(self):
        output = pathlib.Path(self.scratch.name) / 'output.txt'
        result = self.repo.run('release', '--changelog', 'CHANGELOG.md', '--github-output', str(output))
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return dict(line.split('=', 1) for line in output.read_text().splitlines())

    def test_lint_accepts_conventional_subjects(self):
        for message in ('feat: add zip', 'fix(core)!: drop alias', 'docs(readme): fix link\n\nBody text.'):
            self.assertEqual(self.repo.run('lint', '--message', message).returncode, 0, message)

    def test_lint_rejects_nonconforming_messages(self):
        for message in ('Add zip', 'feature: add zip', 'feat:add zip', 'feat: ', 'feat: add zip\nno blank line'):
            self.assertEqual(self.repo.run('lint', '--message', message).returncode, 1, message)

    def test_lint_reads_a_commit_message_file_like_git_records_it(self):
        path = pathlib.Path(self.scratch.name) / 'COMMIT_EDITMSG'
        path.write_text('feat: add zip\n\n# Please enter the commit message.\n# ------------------------ >8 ------------------------\nUpdate stuff\n')
        self.assertEqual(self.repo.run('lint', '--file', str(path)).returncode, 0)

        path.write_text('Update stuff\n# Please enter the commit message.\n')
        self.assertEqual(self.repo.run('lint', '--file', str(path)).returncode, 1)

    def test_lint_checks_every_commit_in_a_range_and_skips_merges(self):
        self.repo.commit('feat: good')
        bad = self.repo.commit('Update stuff')
        self.repo.git('checkout', '-q', '-b', 'side', 'v1.2.3')
        self.repo.commit('fix: side')
        self.repo.git('checkout', '-q', 'main')
        self.repo.git('merge', '-q', '--no-ff', '-m', 'Merge branch side', 'side')

        result = self.repo.run('lint', 'v1.2.3..HEAD')

        self.assertEqual(result.returncode, 1)
        self.assertIn(bad[:7], result.stdout)
        self.assertNotIn('Merge branch', result.stdout)

    def test_fix_bumps_patch(self):
        self.repo.commit('fix: correct count')
        self.assertEqual(self.release()['tag'], 'v1.2.4')

    def test_feat_bumps_minor_and_resets_patch(self):
        self.repo.commit('fix: correct count')
        self.repo.commit('feat: add zip')
        self.assertEqual(self.release()['tag'], 'v1.3.0')

    def test_breaking_change_bumps_major(self):
        self.repo.commit('feat: add zip')
        self.repo.commit('refactor: rename type\n\nBREAKING CHANGE: Box is now Tuple.')
        self.assertEqual(self.release()['tag'], 'v2.0.0')

    def test_wrapped_breaking_footer_keeps_every_line(self):
        self.repo.commit('refactor!: rename package\n\nBREAKING CHANGE: depend on TupleKit and\nimport TupleKit.\nRelease-As: 2.0.0')
        self.release()
        changelog = (pathlib.Path(self.scratch.name) / 'CHANGELOG.md').read_text()
        self.assertIn('- depend on TupleKit and import TupleKit. (', changelog)

    def test_bang_bumps_major(self):
        self.repo.commit('fix!: drop alias')
        self.assertEqual(self.release()['tag'], 'v2.0.0')

    def test_release_as_sets_the_version(self):
        self.repo.commit('feat!: rename package\n\nRelease-As: 6.0.0')
        self.assertEqual(self.release()['tag'], 'v6.0.0')

    def test_release_as_must_be_greater_than_the_last_tag(self):
        self.repo.commit('feat: add zip\n\nRelease-As: 1.0.0')
        self.assertEqual(self.repo.run('release').returncode, 1)

    def test_only_docs_and_chores_release_nothing(self):
        self.repo.commit('docs: explain zip')
        self.repo.commit('chore: tidy')
        self.assertEqual(self.release(), {'released': 'false'})
        self.assertFalse((pathlib.Path(self.scratch.name) / 'CHANGELOG.md').exists())

    def test_changelog_lists_sections_and_prepends_new_releases(self):
        self.repo.commit('feat(api): add zip')
        self.repo.commit('fix: correct count')
        self.repo.commit('refactor!: rename type')
        self.release()
        self.repo.git('tag', 'v2.0.0')
        self.repo.commit('fix: second fix')
        self.release()

        changelog = (pathlib.Path(self.scratch.name) / 'CHANGELOG.md').read_text()

        self.assertEqual(changelog.count('# Changelog'), 1)
        self.assertLess(changelog.index('## v2.0.1'), changelog.index('## v2.0.0'))
        first = changelog[changelog.index('## v2.0.0'):]
        self.assertIn('### Breaking Changes\n\n- rename type', first)
        self.assertIn('### Features\n\n- **api:** add zip', first)
        self.assertIn('### Bug Fixes\n\n- correct count', first)


if __name__ == '__main__':
    unittest.main()
