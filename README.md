# Rust Async Fundamentals — Complete Examples

All the runnable code from the Medium post **[Fundamentals of Asynchronous Execution in Rust](https://medium.com/@yourname/fundamentals-of-asynchronous-execution-in-rust)**.

**Tested with** Rust 1.84.0 + Tokio 1.42.0

## Quick Start

```bash
cargo build --workspace
cargo run -p ex01-basic-async
cargo run -p ex02-spawn-tasks
cargo run -p ex03-join-concurrent
cargo run -p ex04-select-timeout
cargo run -p ex05-spawn-blocking
cargo run -p ex06-fixing-serial
cargo test -p ex07-async-tests
```

## Projects

1. **ex01-basic-async** – tokio::join! for concurrent sleeps
2. **ex02-spawn-tasks** – tokio::spawn for background tasks
3. **ex03-join-concurrent** – Sequential vs concurrent comparison
4. **ex04-select-timeout** – tokio::select! for timeouts
5. **ex05-spawn-blocking** – Offload CPU work to blocking threads
6. **ex06-fixing-serial** – Transform loop-based serial code → concurrent
7. **ex07-async-tests** – Async unit tests with #[tokio::test]

## Learn More

- [Tokio Tutorial](https://tokio.rs/tokio/tutorial)
- [Async Book](https://rust-lang.github.io/async-book/)
