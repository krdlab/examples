use std::{thread, time};
use tokio;

#[tokio::main]
async fn main() {
    let handle = tokio::spawn(async {
        thread::sleep(time::Duration::from_secs(3));
        "return value"
    });

    println!("start task");
    let out = handle.await.unwrap();
    println!("Got {}", out);
}
