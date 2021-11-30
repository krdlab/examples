// Copyright (c) 2021 Sho Kuroda <krdlab@gmail.com>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

use mini_redis::{client, Result};

#[tokio::main]
async fn main() -> Result<()> {
    run_mini_redis().await?;
    run_hello_world().await?;
    Ok(())
}

async fn run_mini_redis() -> Result<()> {
    let mut client = client::connect("127.0.0.1:6379").await?;

    client.set("hello", "world".into()).await?;
    let result = client.get("hello").await?;
    println!("result = {:?}", result);

    Ok(())
}

async fn run_hello_world() -> Result<()> {
    let op = say_world();

    println!("hello");

    op.await;
    Ok(())
}

async fn say_world() {
    println!("world");
}
