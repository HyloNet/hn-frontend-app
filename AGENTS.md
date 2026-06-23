# AI Agent Instructions — HyloNet Hyperlocal News App

## Golden Rules

- **Do not delete anything without explicit permission.** If a file is in the way, move it to `.archive/` and ask before removing.
- **Always commit after completing changes.** Validate locally first, then push to GitHub.
- **Never expose secrets.** Rotate any exposed API key immediately and scrub it from git history.
- **Do not add hardcoded credentials.** Use `.env` files and `AppConfig` for all configuration.
 - **Maintain a change log.** Every change must be recorded in `CHANGELOG.md` with the date, a brief description, and the files affected. Use bullet points and keep entries concise: `- YYYY-MM-DD: description of change`.
 - **Verify changes with analyzer before committing** if the project provides it.
- **Keep changes minimal and focused.** Do not refactor unrelated code.
- **Do not overthink.** If a question or ambiguity arises, ask the user for their decision rather than guessing.
- **Update docs when behavior changes.** FEATURES.md and ANDROID_INTEGRATION.md must stay in sync with code.
- **Work with the layered architecture.** All network calls must flow through `lib/services/api_service.dart`. Screens and widgets should not call `dart:io` or `package:http` directly.

## Workflow

1. Read `FEATURES.md` and `ANDROID_INTEGRATION.md` before making architectural changes.
2. Make the change.
3. Verify changes with analyzer.
4. Run relevant tests.
5. Commit with a clear message.
6. Push to GitHub and confirm CI passes.

## Specific Rules for This Repo

- Application config lives in `lib/config/app_config.dart`. Changes there affect all platforms.
- `.env` is gitignored; `.env.example` is committed and must contain only safe placeholders.
- All API models are in `lib/models/`. Group them by domain (e.g., `auth_models.dart`, `ad.dart`, `news_out.dart`).
- Use `Resource<T>` (Loading / Success / Error) for async UI state.
- Use `ApiService` for all HTTP requests.
- Cached data uses `shared_preferences` with a max age (default 12 hours).
- Android local HTTP development requires `android/app/src/main/res/xml/network_security_config.xml`.
- Endpoint changes must be reflected in both `FEATURES.md` and `ANDROID_INTEGRATION.md`.
