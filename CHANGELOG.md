# Changelog

All notable changes to this action will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-05-12

### Added

- Root `action.yml` and `scripts/` layout for GitHub Marketplace compatibility.
- Documentation: `README.md`, `docs/marketplace.md`, `docs/configuration.md`, `docs/api.md`.
- `LICENSE` (MIT), `SECURITY.md`, and `CHANGELOG.md`.
- Marketplace `branding` (icon and color) in `action.yml`.

### Changed

- **Breaking:** Workflows must reference the repository root, for example `uses: org/coolify-deploy@v1`, instead of a subpath such as `org/coolify-deploy/actions/deploy-via-api@ref`.
