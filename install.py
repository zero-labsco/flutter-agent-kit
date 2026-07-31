#!/usr/bin/env python3
"""install.py — wires the flutter-agent-kit into the developer's AI tools.
install.py — 将 flutter-agent-kit 接入开发者的各类 AI 工具。

Detect installed tools and place/soft-link the appropriate entry file so the
kit's AGENTS.md (single source of truth) is consumed by each tool.
自动检测已安装的工具，并将合适的入口文件放置或软链过去，
让各工具都能读取本套件的 AGENTS.md（单一真相源）。

Run with:  python install.py
运行方式：  python install.py

Cross-platform (Windows / macOS / Linux). Idempotent: re-running is safe.
跨平台（Windows / macOS / Linux），且幂等：重复运行不会产生副作用。
"""

import os
import shutil
import sys

KIT_NAME = "flutter-agent-kit"


def tool_skills_dir(tool):
    """Resolve the user-level skills base directory for a given tool.
    解析某工具的用户级 skills 根目录。

    Returns None if the tool is not detected on this machine.
    若本机未检测到该工具则返回 None。
    """
    home = os.environ.get("HOME") or os.environ.get("USERPROFILE")  # Windows uses USERPROFILE / Windows 使用 USERPROFILE
    if home is None:
        return None

    if tool == "codebuddy":
        # Windows: %USERPROFILE%\.codebuddy ; POSIX: ~/.codebuddy
        # 用户级 skills 目录：Windows 与类 Unix 路径一致。
        return os.path.join(home, ".codebuddy", "skills")
    elif tool == "claude":
        return os.path.join(home, ".claude", "skills")
    return None


def link_kit_for_tool(tool, skills_dir, kit_path):
    """Soft-link (or copy, on platforms without link support) the kit folder
    into the target tool's skills directory.
    将套件目录软链（或拷贝，于不支持软链的平台）到目标工具的 skills 目录。
    """
    target = os.path.join(skills_dir, KIT_NAME)
    if os.path.exists(target):
        print("[skip] {}: {} already present".format(tool, target))
        return
    os.makedirs(skills_dir, exist_ok=True)
    try:
        # Use a symlink so updates are picked up without re-installing.
        # 使用软链，这样套件更新后无需重新安装即可生效。
        os.symlink(kit_path, target)
        print("[link] {} -> {}".format(tool, target))
    except OSError:
        # Fallback: deep copy (Windows may block links without privileges).
        # 兜底：整目录拷贝（Windows 可能因权限不足而禁止创建软链）。
        shutil.copytree(kit_path, target)
        print("[copy] {} -> {}".format(tool, target))


def place_project_entry(entry_path, source):
    """Copy AGENTS.md content into a project-level entry for tools that have no
    user-level skills directory (Cursor / Copilot consume per-project files).
    将 AGENTS.md 内容拷贝到项目级入口，供没有用户级 skills 目录的工具使用
    （Cursor / Copilot 读取的是项目级文件）。
    """
    if os.path.exists(entry_path):
        print("[skip] project entry already exists: {}".format(entry_path))
        return
    os.makedirs(os.path.dirname(entry_path), exist_ok=True)
    shutil.copyfile(source, entry_path)
    print("[copy] AGENTS.md -> {}".format(entry_path))


def find_project_root(start):
    """Walk up from [start] looking for a pubspec.yaml (a Flutter/Dart project).
    从 start 向上查找 pubspec.yaml（即 Flutter/Dart 项目根）。
    """
    dir_ = start
    while True:
        if os.path.exists(os.path.join(dir_, "pubspec.yaml")):
            return dir_
        parent = os.path.dirname(dir_)
        if parent == dir_:  # reached filesystem root / 到达文件系统根
            return None
        dir_ = parent


def main(argv):
    kit_path = os.path.abspath(os.getcwd())
    agents_file = os.path.join(kit_path, "AGENTS.md")
    if not os.path.exists(agents_file):
        sys.stderr.write(
            "AGENTS.md not found in {}. Run install.py from the kit root.\n".format(kit_path)
        )
        return 1

    # 1. CodeBuddy — user-level skills symlink.
    # 1. CodeBuddy —— 用户级 skills 软链。
    cb = tool_skills_dir("codebuddy")
    if cb is not None:
        link_kit_for_tool("codebuddy", cb, kit_path)

    # 2. Claude Code — user-level skills symlink.
    # 2. Claude Code —— 用户级 skills 软链。
    cl = tool_skills_dir("claude")
    if cl is not None:
        link_kit_for_tool("claude", cl, kit_path)

    # 3. Cursor / Copilot — no user-level concept; place into CURRENT project.
    # Detect by walking up for a pubspec.yaml; if found, drop the entry there.
    # 3. Cursor / Copilot —— 没有用户级概念，写入「当前项目」。
    # 向上查找 pubspec.yaml 定位项目根，若找到则把入口放到该处。
    project_root = find_project_root(kit_path)
    if project_root is not None:
        place_project_entry(os.path.join(project_root, ".cursorrules"), agents_file)
        place_project_entry(
            os.path.join(project_root, ".github", "copilot-instructions.md"),
            agents_file,
        )
    else:
        print(
            "[info] No Flutter project found above this kit; skipped "
            "Cursor/Copilot project entries. Run install.py inside a project "
            "to wire those tools."
        )

    print("\nDone. Re-run anytime to update. See README.md for manual fallback.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
