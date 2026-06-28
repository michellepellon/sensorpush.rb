# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0]

Requires Ruby 4.0.0 or higher.

### Security
- `Client#inspect` no longer discloses the password or access token; only
  non-sensitive attributes are shown.

### Changed
- **Breaking:** `authenticate` now raises on failure instead of returning
  `false`. Rejected credentials (HTTP 401/403) raise `AuthenticationError`;
  other non-2xx responses raise `APIError` with `#status` and `#api_message`
  populated. Non-2xx responses are no longer silently swallowed by
  `gateways`/`sensors`/`samples`.
- **Breaking:** Parsed timestamps (`Sample#observed`, `Gateway#last_seen`,
  `Gateway#last_alert`) return `Time` instead of the legacy `DateTime`. Time
  arithmetic differs: `Time - 1` subtracts one *second*, not one *day* (use
  `Time.now - 86_400` for "24 hours ago").
- **Breaking:** `Sensor` and `Gateway` are now `Data` classes, gaining
  value-based equality and frozen instances. Their `inspect` output uses the
  `Data` format (`#<data Sensorpush::Sensor id=..., ...>`) and is no longer
  curated to a subset of attributes.

### Fixed
- `samples` sends ISO 8601 timestamps for `start_time`/`end_time`, so the
  API's time-range filtering works as intended.
- `Sensor#battery_percentage` always returns a `Float` (previously returned an
  `Integer` at the clamp boundaries).
- Wrapped `OpenSSL::SSL::SSLError` as `APIError` instead of leaking it raw.
- Corrected the gemspec `homepage` and derived metadata URLs (and the README
  link) to the `sensorpush.rb` repository, so the advertised `changelog_uri`
  resolves.

### Added
- `CHANGELOG.md` (this file).

## [2.0.0]

Requires Ruby 4.0.0 or higher.

### Added
- Pattern matching support (`deconstruct_keys`) on `Sensor`, `Gateway`, and `Sample`.
- `Sample` is implemented as an immutable `Data` class with value-based equality.
- Specific error classes: `AuthenticationError`, `ParseError`, and `APIError`
  (with `#status` and `#api_message`), all under a shared `Sensorpush::Error`.
- Configurable request `timeout` on the client.

### Changed
- **Breaking:** Ruby 4.0.0 is now required.
- **Breaking:** `Sample` objects are immutable and cannot be modified after creation.
- **Breaking:** `Gateway` and `Sensor` `name` is read-only.
- `samples` accepts keyword arguments (`limit:`, `start_time:`, `end_time:`),
  with the legacy options-hash form still supported.
