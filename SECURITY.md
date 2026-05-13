# Security policy

## Supported versions

Security fixes are applied to the latest minor release line (for example all `v1.x.x` tags). Use a [pinned release tag](https://docs.github.com/en/actions/learn-github-actions/finding-and-customizing-actions#using-tags-for-release-management) in workflows.

## Reporting a vulnerability

Please **do not** open a public issue for undisclosed security problems.

Instead, use one of these options (whichever the repository maintainers have enabled):

- GitHub **Private vulnerability reporting** for this repository (Settings → Security → Code security).
- Or contact the repository owners directly with a clear subject line, reproduction steps, and impact assessment.

You should receive an initial response within a reasonable time frame; maintainers may ask follow-up questions under coordinated disclosure expectations.

## Token handling

The `deploy-api-token` input is sensitive. Always pass it from **`secrets`**, restrict repository and environment secrets to required workflows only, and rotate the token if it may have been exposed in logs.
