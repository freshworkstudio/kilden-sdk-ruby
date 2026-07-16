# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-07-16

First stable release. The public surface and the twelve behavior contracts of
[kilden-sdk-spec](https://github.com/kildenhq/kilden-sdk-spec) are now frozen
under semver: no breaking changes without a major bump.

Graduating out of prerelease also means a plain `gem "kilden"` resolves here —
Bundler ignores prereleases unless the version is spelled out in full.

### Fixed

- `IdentitySigner` escapes the JS line separators U+2028/U+2029 the way Go's
  `encoding/json` does (spec §6.1). This only affects byte-identity with the
  frozen vectors and the other SDKs — tokens signed by the previous release
  verify fine, since the signature covers the payload as transmitted.

### Verified

- End-to-end against production ingest, not just the spec's mock server:
  `track`, `identify` and `alias` land with `source=server`, `verified=true`;
  `IdentitySigner` tokens are accepted by the enricher (a no-token control
  lands `verified=false`); `enabled?` reflects live flag changes.

## [0.1.0.alpha.3] - 2026-07-14

### Changed

- Repository moved to the kildenhq org; releases publish to RubyGems via
  OIDC trusted publishing.

## [0.1.0.alpha.2] - 2026-07-14

### Fixed

- Any 2xx from `/capture` is success; the response body is never parsed
  (spec clarification — a 200 with a corrupt body was retried before).
- The transport detects responses truncated mid-body (connection cut) and
  classifies them as retryable network errors.
- `EventQueue#empty?` was missing, silently killing and respawning the
  worker thread after every batch.

## [0.1.0.alpha.1] - 2026-07-14

### Added

- `Kilden::Client`: `track`, `identify`, `alias`, `flush`, `close` with a
  bounded in-memory queue, background worker, gzip, and retries with
  exponential backoff honoring `Retry-After`.
- Fork safety under preforking servers (puma/unicorn), tested against a real
  `puma -w 2 --preload` in CI.
- `Kilden::IdentitySigner`: hand-rolled HS256 identity tokens, byte-exact
  against the platform's vectors.
- Feature flags: `enabled?` / `feature_flag` over `/decide` with a 30s
  TTL + LRU cache and `person_properties` / `default:` options.
- Frozen rollout hashing (spec §8.3), vector-tested for future local eval.
- Vector runners for the three kilden-sdk-spec vector files, wired into CI
  against the spec's mock capture server.

[Unreleased]: https://github.com/kildenhq/kilden-sdk-ruby/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/kildenhq/kilden-sdk-ruby/compare/v0.1.0-alpha.3...v0.1.0
[0.1.0.alpha.3]: https://github.com/kildenhq/kilden-sdk-ruby/compare/v0.1.0-alpha.2...v0.1.0-alpha.3
[0.1.0.alpha.2]: https://github.com/kildenhq/kilden-sdk-ruby/compare/v0.1.0-alpha.1...v0.1.0-alpha.2
[0.1.0.alpha.1]: https://github.com/kildenhq/kilden-sdk-ruby/releases/tag/v0.1.0-alpha.1
