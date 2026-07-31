#!/usr/bin/env python3
"""bump_version.py — bumps the version in pubspec.yaml per semver.
bump_version.py — 按语义化版本号（semver）递增 pubspec.yaml 中的版本。

Usage:  python scripts/python/bump_version.py <major|minor|patch>
用法：  python scripts/python/bump_version.py <major|minor|patch>
Reads the current `version:` line, increments the chosen segment, writes it
back, and prints the suggested git tag command. Does not run git itself.
读取当前 `version:` 行，递增所选分段并写回，同时打印建议的 git tag 命令（不自动执行 git）。
"""

import os
import re
import sys

VERSION_RE = re.compile(r"^(version:\s*)(\d+)\.(\d+)\.(\d+)(.*)$")


def main(argv):
    if len(argv) < 1:
        sys.stderr.write("Usage: python scripts/python/bump_version.py <major|minor|patch>\n")
        return 1

    kind = argv[0]
    if kind not in ("major", "minor", "patch"):
        sys.stderr.write("Kind must be one of: major, minor, patch.\n")
        return 1

    path = os.path.join(os.getcwd(), "pubspec.yaml")
    if not os.path.exists(path):
        sys.stderr.write("pubspec.yaml not found in the current directory.\n")
        return 1

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    idx = next((i for i, l in enumerate(lines) if l.startswith("version:")), -1)
    if idx < 0:
        sys.stderr.write('No "version:" field found in pubspec.yaml.\n')
        return 1

    m = VERSION_RE.match(lines[idx].rstrip("\n"))
    if not m:
        sys.stderr.write('Could not parse the version string: "{}".\n'.format(lines[idx].strip()))
        return 1

    prefix, major, minor, patch, suffix = (
        m.group(1), int(m.group(2)), int(m.group(3)), int(m.group(4)), m.group(5)
    )

    if kind == "major":
        major, minor, patch = major + 1, 0, 0
    elif kind == "minor":
        minor, patch = minor + 1, 0
    else:
        patch += 1

    new_version = "{}.{}.{}{}".format(major, minor, patch, suffix)
    lines[idx] = "{}{}\n".format(prefix, new_version)
    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print("Bumped version to {}".format(new_version))
    print("Next steps:")
    print("  git add pubspec.yaml")
    print('  git commit -m "chore: bump version to {}"'.format(new_version))
    print("  git tag v{} && git push origin v{}".format(new_version, new_version))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
