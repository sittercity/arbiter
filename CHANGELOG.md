# Arbiter

## 3.0.1

- Remove required dependencies

## 3.0.0

- Changed away from ruby 'Marshal' in favor of sending parameters via 'MultiJSON' when communicating with Majordomo in the Async Arbiter.

## 2.0.0

- Removed plain ZeroMQ Push/Pull Arbiter implementation. We don't use it locally and to be honest it's not worth the effort to attempt to update it since we use the Majordomo pattern internally. Let us know via an issue if you use it and would see value in us adding it back.
- Added new ZeroMQ::MajordomoAsynchronousArbiter. See README for usage details.
- Bump ffi-rzmq dependency to ~>2.0. We use this internally.
