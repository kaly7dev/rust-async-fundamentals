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
