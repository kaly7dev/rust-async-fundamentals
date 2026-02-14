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
