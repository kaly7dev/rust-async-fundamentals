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
