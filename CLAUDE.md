# HomeMix - Project Instructions

## Project overview

HomeMix is a Flutter app for discovering drink recipes, managing a pantry, mixing recommendations, learning, guided practice, and a drink journal.

## Tech and structure

- Flutter / Dart (SDK constraint: `^3.13.4`).
- State management: Riverpod (`flutter_riverpod`); navigation: `go_router`.
- Firebase packages are configured alongside local persistence (`shared_preferences`) and mock repositories. Check the existing implementation before choosing or changing a data source.
- `lib/app/`: app setup, routing, shell, and theme.
- `lib/core/`: shared utilities, errors, constants, and widgets.
- `lib/features/<feature>/`: feature-specific presentation, providers, domain, data, and widgets.
- `lib/domain/` and `lib/data/`: shared domain contracts and data implementations.
- `test/`: feature tests and shared test support.

## Working guidelines

- Follow the existing feature-first structure and nearby Dart style; keep changes focused.
- Keep domain models and repository contracts separate from UI. Use Riverpod providers to expose state and dependencies.
- Reuse existing shared widgets, theme values, and routing patterns instead of duplicating them.
- Preserve localization and user-facing Vietnamese text where already used.
- Add or update focused tests for behavior changes. Do not edit generated or platform files unless the task requires it.
- Never commit credentials or secrets; treat Firebase configuration and platform setup carefully.

## Validation

- Run `flutter analyze` for static analysis.
- Run `flutter test` for the test suite, or pass a specific test file to target a change.
