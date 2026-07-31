# Plugin Platform Channel Reference

Companion to `AGENTS.md`. Template and rules for Flutter plugins that bridge to
native Android/iOS (extensible to other platforms).

## Layered pattern (keep this for every plugin)
1. **Platform interface** (`lib/<pkg>_platform_interface.dart`)
   - Abstract class `<Pkg>Platform extends PlatformInterface`.
   - Declares the public async API (`Future<T> doThing(...)`).
   - Provides a `instance` setter so the default impl can register itself.
2. **Method channel impl** (`lib/<pkg>_method_channel.dart`)
   - `class <Pkg>MethodChannelPlatform extends <Pkg>Platform`.
   - Holds a `MethodChannel` and forwards calls; returns typed results.
3. **Barrel** (`lib/<pkg>.dart`)
   - Exports the public API + the platform interface; sets the default instance.
   - Never export `lib/src/` or the method-channel class directly.

## Method channel contract
- One `MethodChannel('<com.example.pkg>/methods')` per plugin; method names are strings.
- Pass plain serializable args (Map/List/primitives); encode complex objects yourself.
- Handle `PlatformException` on the Dart side; surface a typed error, don't leak native traces.
- Native must reply on the same channel; use `result.success(...)` / `result.error(...)`.

## Native side
- Android: `android/src/main/kotlin/com/example/pkg/<Pkg>Plugin.kt`, package matches the channel prefix.
- iOS: `ios/Classes/<Pkg>Plugin.swift`, registered in `registerWithRegistrar`.
- Keep native changes minimal; they exist only to fulfill the method-channel contract.

## Cross-platform beyond Android/iOS
Add `<Pkg>Web` / `<Pkg>Linux` etc. by implementing the same platform interface and
registering conditionally. Consumers stay unchanged because they call the abstract API.

## Release notes
- Bump `version` in `pubspec.yaml`; update `CHANGELOG.md`.
- `flutter pub publish --dry-run` before publishing; `k-paxian/dart-package-publisher` is one CI option.
- Do not pass OIDC fields to that publisher action; it uses access/refresh tokens only.
