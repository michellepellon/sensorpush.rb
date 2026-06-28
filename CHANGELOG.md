# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
