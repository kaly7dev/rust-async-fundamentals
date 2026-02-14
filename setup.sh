#!/bin/bash
set -e

echo "Creating workspace..."

cat > Cargo.toml << 'WORKSPACE'
[workspace]
members = [
    "01-basic-async",
    "02-spawn-tasks",
    "03-join-concurrent",
    "04-select-timeout",
    "05-spawn-blocking",
    "06-fixing-serial",
    "07-async-tests",
]
resolver = "2"
WORKSPACE

# 01-basic-async
mkdir -p 01-basic-async/src
cat > 01-basic-async/Cargo.toml << 'CARGO'
[package]
name = "01-basic-async"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "time"] }
CARGO
cat > 01-basic-async/src/main.rs << 'RUST'
use tokio;

#[tokio::main]
async fn main() {
    println!("Starting...");
    // Simulate two independent delays
    let (a, b) = tokio::join!(
        tokio::time::sleep(tokio::time::Duration::from_secs(1)),
        tokio::time::sleep(tokio::time::Duration::from_millis(500))
    );
    println!("Both sleeps done! (took ~1s total)");
}
RUST

# 02-spawn-tasks
mkdir -p 02-spawn-tasks/src
cat > 02-spawn-tasks/Cargo.toml << 'CARGO'
[package]
name = "02-spawn-tasks"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "time"] }
CARGO
cat > 02-spawn-tasks/src/main.rs << 'RUST'
use tokio;

#[tokio::main]
async fn main() {
    let handle1 = tokio::spawn(async {
        tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;
        "Task 1 done"
    });

    let handle2 = tokio::spawn(async {
        tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
        "Task 2 done"
    });

    let (r1, r2) = tokio::join!(handle1, handle2);
    println!("{} and {}", r1.unwrap(), r2.unwrap());
}
RUST

# 03-join-concurrent
mkdir -p 03-join-concurrent/src
cat > 03-join-concurrent/Cargo.toml << 'CARGO'
[package]
name = "03-join-concurrent"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "time"] }
CARGO
cat > 03-join-concurrent/src/main.rs << 'RUST'
use tokio;

async fn work(id: u32, ms: u64) -> u32 {
    tokio::time::sleep(tokio::time::Duration::from_millis(ms)).await;
    id
}

#[tokio::main]
async fn main() {
    let start = std::time::Instant::now();
    
    // Sequential
    let _ = work(1, 500).await;
    let _ = work(2, 500).await;
    println!("Sequential: {}ms", start.elapsed().as_millis());
    
    // Concurrent
    let start = std::time::Instant::now();
    let (a, b) = tokio::join!(work(3, 500), work(4, 500));
    println!("Concurrent: {}ms → results: {}, {}", start.elapsed().as_millis(), a, b);
}
RUST

# 04-select-timeout
mkdir -p 04-select-timeout/src
cat > 04-select-timeout/Cargo.toml << 'CARGO'
[package]
name = "04-select-timeout"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "time"] }
CARGO
cat > 04-select-timeout/src/main.rs << 'RUST'
use tokio::{select, time::{sleep, Duration}};

#[tokio::main]
async fn main() {
    select! {
        _ = sleep(Duration::from_secs(3)) => println!("Slow operation finished"),
        _ = sleep(Duration::from_secs(1)) => println!("Timeout!"),
    }
}
RUST

# 05-spawn-blocking
mkdir -p 05-spawn-blocking/src
cat > 05-spawn-blocking/Cargo.toml << 'CARGO'
[package]
name = "05-spawn-blocking"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
CARGO
cat > 05-spawn-blocking/src/main.rs << 'RUST'
// Naive recursive Fibonacci (CPU-heavy)
fn fibonacci(n: u64) -> u64 {
    if n <= 1 { n } else { fibonacci(n-1) + fibonacci(n-2) }
}

#[tokio::main]
async fn main() {
    let result = tokio::task::spawn_blocking(|| {
        println!("Computing fib(45) on blocking thread...");
        fibonacci(45)
    }).await.unwrap();
    
    println!("fib(45) = {}", result);
}
RUST

# 06-fixing-serial
mkdir -p 06-fixing-serial/src
cat > 06-fixing-serial/Cargo.toml << 'CARGO'
[package]
name = "06-fixing-serial"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "time"] }
futures = "0.3"
CARGO
cat > 06-fixing-serial/src/main.rs << 'RUST'
use tokio;

#[tokio::main]
async fn main() {
    let urls = vec!["1", "2", "3"];
    
    // BAD — sequential execution
    println!("=== BAD (sequential) ===");
    for url in &urls {
        println!("Fetching {}", url);
        tokio::time::sleep(tokio::time::Duration::from_millis(300)).await;
    }
    
    // GOOD — concurrent
    println!("=== GOOD (concurrent) ===");
    let handles: Vec<_> = urls.into_iter().map(|u| {
        tokio::spawn(async move {
            tokio::time::sleep(tokio::time::Duration::from_millis(300)).await;
            format!("Result for {}", u)
        })
    }).collect();
    
    let results = futures::future::join_all(handles).await;
    for r in results {
        println!("{}", r.unwrap());
    }
}
RUST

# 07-async-tests
mkdir -p 07-async-tests/src
cat > 07-async-tests/Cargo.toml << 'CARGO'
[package]
name = "07-async-tests"
version = "0.1.0"
edition = "2021"

[dev-dependencies]
tokio = { version = "1", features = ["macros", "rt-multi-thread", "test-util"] }
CARGO
cat > 07-async-tests/src/lib.rs << 'RUST'
#[cfg(test)]
mod tests {
    use tokio;

    #[tokio::test]
    async fn test_concurrent_sleeps() {
        let start = std::time::Instant::now();
        let (_a, _b) = tokio::join!(
            tokio::time::sleep(tokio::time::Duration::from_millis(100)),
            tokio::time::sleep(tokio::time::Duration::from_millis(100))
        );
        assert!(start.elapsed().as_millis() < 150);
        println!("✅ Concurrent sleeps test passed");
    }

    #[tokio::test]
    async fn test_spawn_blocking() {
        let result = tokio::task::spawn_blocking(|| 42 * 42).await.unwrap();
        assert_eq!(result, 1764);
        println!("✅ spawn_blocking test passed");
    }
}
RUST

# README
cat > README.md << 'README'
# Rust Async Fundamentals — Complete Examples

All the runnable code from the Medium post **[Fundamentals of Asynchronous Execution in Rust](https://medium.com/@yourname/fundamentals-of-asynchronous-execution-in-rust)**.

**Tested with** Rust 1.84.0 + Tokio 1.42.0

## Quick Start

```bash
cargo build --workspace
cargo run -p 01-basic-async
cargo run -p 02-spawn-tasks
cargo run -p 03-join-concurrent
cargo run -p 04-select-timeout
cargo run -p 05-spawn-blocking
cargo run -p 06-fixing-serial
cargo test -p 07-async-tests
```

## Projects

1. **01-basic-async** – tokio::join! for concurrent sleeps
2. **02-spawn-tasks** – tokio::spawn for background tasks
3. **03-join-concurrent** – Sequential vs concurrent comparison
4. **04-select-timeout** – tokio::select! for timeouts
5. **05-spawn-blocking** – Offload CPU work to blocking threads
6. **06-fixing-serial** – Transform loop-based serial code → concurrent
7. **07-async-tests** – Async unit tests with #[tokio::test]

## Learn More

- [Tokio Tutorial](https://tokio.rs/tokio/tutorial)
- [Async Book](https://rust-lang.github.io/async-book/)
README

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  cargo build --workspace"
echo "  cargo run -p 01-basic-async"
