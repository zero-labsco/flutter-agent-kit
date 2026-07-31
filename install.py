#!/usr/bin/env python3
"""install.py — wires the flutter-agent-kit into the developer's AI tools.
install.py — 将 flutter-agent-kit 接入开发者的各类 AI 工具。

Detect installed tools and place/soft-link the appropriate entry file so the
kit's AGENTS.md (single source of truth) is consumed by each tool.
自动检测已安装的工具，并将合适的入口文件放置或软链过去，
让各工具都能读取本套件的 AGENTS.md（单一真相源）。

Run with:  python install.py
运行方式：  python install.py

Optional: pass a target project root so Cursor/Copilot entries are placed
there directly, instead of scanning upward from the kit folder.
可选：传入目标项目根目录，让 Cursor/Copilot 入口直接写入该项目，
而不是从 kit 目录向上查找。
  python install.py --project /path/to/my_project
  python install.py /path/to/my_project
  python install.py -p /path/to/my_project -t cursor   # only Cursor
  python install.py -h                                  # show help

All flags are optional; run with no args to wire every detected tool.
所有参数均可选；不带参数运行即接入所有已检测到的工具。

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
    # Windows uses USERPROFILE; POSIX uses HOME. / Windows 用 USERPROFILE，类 Unix 用 HOME。
    home = os.environ.get("HOME") or os.environ.get("USERPROFILE")
    if home is None:
        return None

    if tool == "codebuddy":
        # Windows: %USERPROFILE%\.codebuddy ; POSIX: ~/.codebuddy
        # 用户级 skills 目录：Windows 与类 Unix 路径一致。
        return os.path.join(home, ".codebuddy", "skills")
    if tool == "claude":
        return os.path.join(home, ".claude", "skills")
    return None


def link_kit_for_tool(tool, skills_dir, kit_path):
    """Soft-link (or copy, on platforms without link support) the kit folder
    into the target tool's skills directory.
    将套件目录软链（或拷贝，于不支持软链的平台）到目标工具的 skills 目录。
    """
    target = os.path.join(skills_dir, KIT_NAME)
    if os.path.exists(target):
        print(f"[skip] {tool}: {target} already present")
        return
    os.makedirs(skills_dir, exist_ok=True)
    try:
        # Use a symlink so updates are picked up without re-installing.
        # 使用软链，这样套件更新后无需重新安装即可生效。
        os.symlink(kit_path, target)
        print(f"[link] {tool} -> {target}")
    except OSError:
        # Fallback: deep copy (Windows may block links without privileges).
        # 兜底：整目录拷贝（Windows 可能因权限不足而禁止创建软链）。
        shutil.copytree(kit_path, target)
        print(f"[copy] {tool} -> {target}")


def place_project_entry(entry_path, source):
    """Copy AGENTS.md content into a project-level entry for tools that have no
    user-level skills directory (Cursor / Copilot consume per-project files).
    将 AGENTS.md 内容拷贝到项目级入口，供没有用户级 skills 目录的工具使用
    （Cursor / Copilot 读取的是项目级文件）。
    """
    if os.path.exists(entry_path):
        print(f"[skip] project entry already exists: {entry_path}")
        return
    os.makedirs(os.path.dirname(entry_path), exist_ok=True)
    shutil.copyfile(source, entry_path)
    print(f"[copy] AGENTS.md -> {entry_path}")


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


def parse_project_arg(argv):
    """Parse the optional target project root from CLI args (or None).
    解析命令行中可选的目标项目根目录（未传则返回 None）。

    Accepts `--project <path>` or a bare positional `<path>`.
    支持 `--project <path>` 或裸位置参数 `<path>`。
    """
    for i, a in enumerate(argv):
        if a in ("--project", "-p"):
            if i + 1 < len(argv):
                return argv[i + 1]
        elif a.startswith("--project="):
            return a.split("=", 1)[1]
        elif not a.startswith("-") and i == len(argv) - 1:
            # A bare trailing path argument. / 末尾的裸路径参数。
            return a
    return None


def parse_tool_arg(argv):
    """Parse the optional `--tool` / `-t` filter (or None = wire all tools).
    解析可选的 `--tool` / `-t` 过滤（None 表示接入全部工具）。

    Valid values: codebuddy, claude, cursor, copilot.
    合法取值：codebuddy、claude、cursor、copilot。
    """
    for i, a in enumerate(argv):
        if a in ("--tool", "-t"):
            if i + 1 < len(argv):
                return argv[i + 1].lower()
        elif a.startswith("--tool="):
            return a.split("=", 1)[1].lower()
    return None


def print_usage():
    """Print the usage text. 打印用法说明。"""
    print(
        """
Flutter Agent Kit installer — wires AGENTS.md into your AI tools.

Usage / 用法:
  python install.py [options]

Options / 选项:
  -p, --project <path>   Target project root for Cursor/Copilot entries.
                         Cursor/Copilot 入口写入的目标项目根目录。
  -t, --tool <tool>      Wire only one tool: codebuddy|claude|cursor|copilot.
                         只接入单个工具（不指定则接入全部已检测到的工具）。
  -h, --help             Show this help and exit. 显示帮助并退出。

Examples / 示例:
  python install.py
  python install.py -p /path/to/project
  python install.py -p /path/to/project -t cursor
"""
    )


def main(argv):
    """Wire the kit into detected AI tools based on CLI flags.
    根据命令行参数将套件接入已检测到的 AI 工具。

    Flags: -p/--project <path>, -t/--tool <tool>, -h/--help.
    参数：-p/--project <path>、-t/--tool <tool>、-h/--help。
    """
    # Show help and exit early (works in any shell: cmd / pwsh / bash).
    # 提前显示帮助并退出（在 cmd / pwsh / bash 等任意 shell 下均可用）。
    if "-h" in argv or "--help" in argv:
        print_usage()
        return 0

    kit_path = os.path.abspath(os.getcwd())
    agents_file = os.path.join(kit_path, "AGENTS.md")
    if not os.path.exists(agents_file):
        sys.stderr.write(
            f"AGENTS.md not found in {kit_path}. Run install.py from the kit root.\n"
        )
        return 1

    # Resolve the optional tool filter. None means "wire every detected tool".
    # 解析可选的工具过滤；None 表示「接入所有已检测到的工具」。
    only_tool = parse_tool_arg(argv)

    def wire(tool):
        """True if [tool] should be wired (no filter, or matches -t)."""
        return only_tool is None or only_tool == tool

    # 1. CodeBuddy — user-level skills symlink.
    # 1. CodeBuddy —— 用户级 skills 软链。
    if wire("codebuddy"):
        cb = tool_skills_dir("codebuddy")
        if cb is not None:
            link_kit_for_tool("codebuddy", cb, kit_path)

    # 2. Claude Code — user-level skills symlink.
    # 2. Claude Code —— 用户级 skills 软链。
    if wire("claude"):
        cl = tool_skills_dir("claude")
        if cl is not None:
            link_kit_for_tool("claude", cl, kit_path)

    # 3. Cursor / Copilot — no user-level concept; place into a target project.
    # Use an explicitly passed --project path if given; otherwise walk up from
    # the kit folder looking for a pubspec.yaml.
    # 3. Cursor / Copilot —— 没有用户级概念，写入「目标项目」。
    # 若显式传入 --project 则用之；否则从 kit 目录向上查找 pubspec.yaml。
    project_arg = parse_project_arg(argv)
    project_root = (
        os.path.abspath(project_arg) if project_arg is not None else find_project_root(kit_path)
    )
    if project_root is not None:
        if wire("cursor"):
            place_project_entry(os.path.join(project_root, ".cursorrules"), agents_file)
        if wire("copilot"):
            place_project_entry(
                os.path.join(project_root, ".github", "copilot-instructions.md"),
                agents_file,
            )
    elif only_tool in ("cursor", "copilot"):
        print(
            "[info] No target project resolved (no --project arg and no "
            "Flutter project found above this kit). Re-run with --project "
            "<path> to wire Cursor/Copilot."
        )

    print("\nDone. Re-run anytime to update. See README.md for manual fallback.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
