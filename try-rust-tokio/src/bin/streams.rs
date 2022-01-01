use mini_redis::client;
use tokio_stream::StreamExt;

#[tokio::main]
async fn main() -> mini_redis::Result<()> {
    basic().await?;

    tokio::spawn(async { publish().await });
    subscribe().await?;
    println!("done");
    Ok(())
}

async fn basic() -> mini_redis::Result<()> {
    let mut stream = tokio_stream::iter(&[1, 2, 3]);

    while let Some(v) = stream.next().await {
        println!("Got {:?}", v);
    }

    Ok(())
}

async fn publish() -> mini_redis::Result<()> {
    let mut client = client::connect("127.0.0.1:6379").await?;
    for i in 1..10 {
        client.publish("numbers", i.to_string().into()).await?;
    }
    Ok(())
}

async fn subscribe() -> mini_redis::Result<()> {
    let client = client::connect("127.0.0.1:6379").await?;
    let subscriber = client.subscribe(vec!["numbers".to_string()]).await?;
    let messages = subscriber.into_stream();

    tokio::pin!(messages);

    while let Some(msg) = messages.next().await {
        println!("Got {:?}", msg);
    }

    Ok(())
}
