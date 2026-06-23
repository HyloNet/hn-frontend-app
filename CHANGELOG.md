# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2026-06-23

### Added
- Flutter service layer (`lib/services/api_service.dart`) with all API endpoints from ANDROID_INTEGRATION.md
- API models for all backend schemas: `NewsOut`, `ArticleOut`, `Ad`, `LocationCreate`/`LocationOut`, `UserRegister`/`UserLogin`/`UserOut`, `ApiHealth`, `GeminiTestResponse`
- `Resource<T>` wrapper (`lib/services/api_result.dart`) for Loading/Success/Error states
- Centralized configuration via `flutter_dotenv` (`.env`, `.env.example`, `.env.development`, `lib/config/app_config.dart`)
- Android network security config (`android/app/src/main/res/xml/network_security_config.xml`) allowing local HTTP traffic
- AGENTS.md with Flutter-tailored development rules

### Changed
- Home feed screen refactored to use `ApiService` instead of raw `http` calls
- API base URL is now environment-configurable via `.env` instead of hardcoded IP
- Android `AndroidManifest.xml` references `@xml/network_security_config`
- App initialization loads environment config before `runApp`
- Geolocator API updated to use `LocationSettings` instead of deprecated `desiredAccuracy`

### Fixed
- Removed hardcoded local IP address from UI layer
