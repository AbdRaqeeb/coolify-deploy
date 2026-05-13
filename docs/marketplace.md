# Publishing to GitHub Marketplace

Follow [GitHub’s official guide](https://docs.github.com/en/actions/sharing-automations/creating-actions/publishing-actions-in-github-marketplace). Summary of requirements that affect **this** repository:

## Repository rules

1. **Public repository** — Marketplace listings are for public actions.
2. **Single `action.yml` at the repository root** — Subfolder-only actions are not automatically listed on the Marketplace. This repo keeps [`action.yml`](../action.yml) at the root and implementation scripts under [`scripts/`](../scripts/).
3. **No workflow files** — GitHub’s documentation states that a Marketplace action repository **must not contain workflow files** (`.github/workflows`). Do not add CI workflows here if you need an unrestricted Marketplace listing; run tests elsewhere or confirm the current policy in GitHub Docs before adding workflows.
4. **Unique `name` in `action.yml`** — The `name` field must not collide with an existing Marketplace action name, a GitHub username/org (unless you own that name), or reserved names.

## Metadata checklist

- [x] `name`, `description`, `runs` defined in `action.yml`
- [x] `branding.icon` (Feather icon name) and `branding.color` for the listing badge
- [x] `description` kept short (GitHub recommends about **125 characters** for Marketplace display)
- [x] `LICENSE` present in the repo (standard practice and expected by consumers)

## Release process

1. Accept the **GitHub Marketplace Developer Agreement** (linked from the release UI when you publish).
2. Commit and push your changes on the default branch.
3. Open **Releases** → **Draft a new release**.
4. Create a new tag (for example `v1.0.0`). Many publishers also maintain a floating **`v1`** tag that points at the latest compatible `v1.x.x` commit.
5. Enable **Publish this Action to the GitHub Marketplace** on the release.
6. Pick **Primary category** (and optional secondary) so users can discover the action.

Use [semantic versioning](https://semver.org/) for tags. Document breaking changes in [CHANGELOG.md](../CHANGELOG.md).

## After publishing

Consumers should pin `uses: owner/repo@<tag>` to an immutable or release tag, not `@main`, for stable CI/CD.
