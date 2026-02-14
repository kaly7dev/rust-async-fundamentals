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
