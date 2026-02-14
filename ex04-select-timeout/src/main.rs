use tokio::{select, time::{sleep, Duration}};

#[tokio::main]
async fn main() {
    select! {
        _ = sleep(Duration::from_secs(3)) => println!("Slow operation finished"),
        _ = sleep(Duration::from_secs(1)) => println!("Timeout!"),
    }
}
