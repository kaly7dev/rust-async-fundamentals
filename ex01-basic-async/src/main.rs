use tokio;

#[tokio::main]
async fn main() {
    println!("Starting...");
    // Simulate two independent delays
    let (_a, _b) = tokio::join!(
        tokio::time::sleep(tokio::time::Duration::from_secs(1)),
        tokio::time::sleep(tokio::time::Duration::from_millis(500))
    );
    println!("Both sleeps done! (took ~1s total)");
}
