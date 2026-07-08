# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0]

Requires Ruby 4.0.0 or higher. Everything since 0.1.0 ships in this release;
the 2.0.0/3.0.0 numbers that briefly appeared in this file were never
published and are folded in here.

### Security
- `Client#inspect` no longer discloses the password or access token; only
  non-sensitive attributes are shown.

### Changed
- **Breaking:** Ruby 4.0.0 is now required.
- **Breaking:** `authenticate` now raises on failure instead of returning
  `false`. Rejected credentials (HTTP 401/403) raise `AuthenticationError`;
  other non-2xx responses raise `APIError` with `#status` and `#api_message`
  populated. Non-2xx responses are no longer silently swallowed by
  `gateways`/`sensors`/`samples`.
- **Breaking:** Parsed timestamps (`Sample#observed`, `Gateway#last_seen`,
  `Gateway#last_alert`) return `Time` instead of the legacy `DateTime`. Time
  arithmetic differs: `Time - 1` subtracts one *second*, not one *day* (use
  `Time.now - 86_400` for "24 hours ago").
- **Breaking:** `Sample`, `Sensor`, and `Gateway` are immutable `Data` classes
  with value-based equality; `Gateway` and `Sensor` `name` is read-only. Their
  `inspect` output uses the `Data` format
  (`#<data Sensorpush::Sensor id=..., ...>`) and is no longer curated to a
  subset of attributes.
- `samples` accepts keyword arguments (`limit:`, `start_time:`, `end_time:`),
  with the legacy options-hash form still supported.

### Fixed
- `samples` now sends the API's `stopTime` parameter for the `end_time`
  keyword. It previously sent `endTime`, which the API silently ignores (the
  official Swagger definition names the parameter `stopTime`), so the upper
  bound of a requested time range never applied. The Ruby-side `end_time:`
  keyword is unchanged.
- `samples` sends ISO 8601 timestamps for `start_time`/`end_time`, so the
  API's time-range filtering works as intended.
- `Sensor#battery_percentage` always returns a `Float` (previously returned an
  `Integer` at the clamp boundaries).
- Wrapped `OpenSSL::SSL::SSLError` as `APIError` instead of leaking it raw.
- Corrected the gemspec `homepage` and derived metadata URLs (and the README
  link) to the `sensorpush.rb` repository, so the advertised `changelog_uri`
  resolves.

### Added
- Pattern matching support (`deconstruct_keys`) on `Sensor`, `Gateway`, and
  `Sample`.
- Specific error classes: `AuthenticationError`, `ParseError`, and `APIError`
  (with `#status` and `#api_message`), all under a shared `Sensorpush::Error`.
- Configurable request `timeout` on the client.
- `CHANGELOG.md` (this file).

## [0.1.0]

Initial release: authentication, `gateways`, `sensors`, and `samples` against
the SensorPush Gateway Cloud API.
