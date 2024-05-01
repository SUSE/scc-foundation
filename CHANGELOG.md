## [Unreleased]

## [0.1.1] - 2024-05-01

- Add a thin layer on top of `ActiveSupport::Instrumentation`
- Bugfix on `Scc::Instrumentable`: Pass the block down to
  `ActiveSupport::Notifications` with `&block` notation instead of `block&.call`
  to the preserve original behavior.

## [0.1.0] - 2024-01-31

- Initial release
