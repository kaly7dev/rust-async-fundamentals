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
