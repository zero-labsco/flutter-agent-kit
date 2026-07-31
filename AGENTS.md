# Flutter Agent Kit - General Guidance

This file is the **single source of truth** for general Flutter / Dart development guidance distributed via the `flutter-agent-kit` repository. It is tool-agnostic: CodeBuddy, Claude Code, Cursor, GitHub Copilot, and Codex can all read and follow it. Keep substantive guidance here; do not let tool-specific wrappers (e.g. `SKILL.md`) hold duplicate content.

## Scope
Applies to **any** Flutter / Dart project, covering two scenarios:
- **Application projects** — UI apps with `lib/`, state management, networking, persistence.
- **Plugin projects** — packages exposing a platform channel for Android/iOS (and beyond).

Guidance here is community consensus. Project-specific rules (exact package names, CI configs, directory depth) belong in each project's own `AGENTS.md`, not here.

## Coding conventions
- Follow `effective_dart`. Enforce with `flutter analyze` and `flutter_lints`.
- Use null safety; avoid `!` unless proven safe. Prefer `final` and immutable models.
- Name files `snake_case.dart`, classes `PascalCase`, constants `lowerCamelCase` or `kConstant`.
- Keep `lib/` free of business logic leakage into UI; separate data / domain / presentation.
- Do not write hardcoded secrets; use `--dart-define` or a `.env` excluded from VCS.

## Dependencies and versioning
- Prefer the caret (`^`) constraint on pub dependencies; do not pin exact versions without reason.
- Keep `sdk` constraints realistic (e.g. `>=3.0.0 <4.0.0`); do not over-constrain.
- Run `flutter pub upgrade` and commit `pubspec.lock` for applications; plugins should also commit it for the example.
- Before publishing: `flutter pub publish --dry-run` to catch missing files and score `pana`.

## Architecture (application)
- Use a **feature-first** layout: `lib/features/<feature>/{data,domain,presentation}/`.
- Or a **layer-first** layout for small apps: `lib/data/`, `lib/domain/`, `lib/presentation/`.
- Choose state management deliberately: `Provider`/`Riverpod` for scoped DI, `Bloc`/`Cubit` for event-driven flows, `GetIt` for service locators. Document the choice in the project README.
- Never import `lib/src/` of a dependency directly; use its public API only.

## Architecture (plugin)
- Define the abstract API once in `lib/<pkg>_platform_interface.dart` (`<Pkg>Platform`).
- Provide a concrete impl per target platform: `MethodChannel` for Android / iOS / macOS / Linux / Windows / OpenHarmony (鸿蒙), and pure-Dart `dart:js_interop` for Web (no MethodChannel).
- Register the right impl conditionally (use `kIsWeb` + `dart:io` `Platform.isX`) in the public barrel; re-export public symbols only. Consumers call the abstract API and never change when a platform is added.
- Keep native changes minimal and matching the method-channel contract. Android lives under `android/src/main/kotlin/...`, iOS/macOS under `ios/Classes` / `macos/Classes`, Linux/Windows under `linux/` / `windows/` (C++), OHOS under `ohos/` (ArkTS).
- See `references/platform_channel.md` for a full multi-platform template.

## Verification commands (run locally before pushing)
- `flutter analyze` — must pass with no errors.
- `flutter test` — all unit tests green.
- `flutter pub publish --dry-run` — confirm `pana` score and no excluded files.

## Helper scripts
Located in `scripts/dart/` (Dart, cross-platform, runs on the Dart SDK every Flutter
dev already has) and `scripts/python/` (Python, for environments without the Dart
SDK). Both implement the same behavior and CLI; pick whichever fits your environment.

Run Dart with `dart run scripts/dart/<name>.dart [args]`, or Python with
`python scripts/python/<name>.py [args]` (or `python3`).

- `verify` — runs analyze + test + publish dry-run. `[--no-publish]` skips the publish check.
- `create_feature <name>` — scaffolds a feature-first folder (`lib/features/<name>/{data,domain,presentation}/`).
- `bump_version <major|minor|patch>` — bumps `pubspec.yaml` and prints the git tag command.

## License note
This kit is licensed separately from any project it guides. Respect each project's own license.
