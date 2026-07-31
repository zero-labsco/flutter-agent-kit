# Application Architecture Reference

Companion to `AGENTS.md`. Decision guidance for structuring a Flutter app's `lib/`.

## Layout: feature-first (recommended for non-trivial apps)
```
lib/
  core/            # cross-cutting: constants, theme, router, di, utils
  features/
    auth/
      data/        # models, repositories, data sources (api, local)
      domain/      # entities, use cases, repository interfaces
      presentation/# pages, widgets, state (bloc/riverpod/cubit)
    profile/
      ...
  main.dart
```
- Keeps a feature's code colocated; scales better than layer-first.
- `domain` depends on nothing but itself; `data` implements `domain` interfaces; `presentation` calls `domain`.

## Layout: layer-first (fine for small apps)
```
lib/
  data/ domain/ presentation/ (or ui/) core/
```
Simpler to reason about at the start; refactor to feature-first as it grows.

## State management selection
- **Riverpod / Provider** — scoped DI + reactive state; low boilerplate; good default.
- **Bloc / Cubit** — event-driven, explicit states, great for complex flows and testability.
- **GetIt + injectable** — service-locator DI; pair with any state solution.
- Pick ONE primary approach per project; document it in the README.

## Rules of thumb
- UI (presentation) must not contain business logic; delegate to use cases / services.
- Dependencies point inward (presentation → domain → data); never the reverse.
- Models are immutable `final` classes; use `freezed`/`equatable` for value equality.
- Keep `lib/` importable as a unit; do not reach into another package's `lib/src/`.

## Testing layering
- `domain` — pure unit tests (fast, no Flutter).
- `data` — unit tests with mocked sources; verify mapping & error handling.
- `presentation` — widget tests for critical flows; integration tests for end-to-end.
