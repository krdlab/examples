use tokio::fs::File;
use tokio::io::{AsyncReadExt, AsyncWriteExt, Result};

#[tokio::main]
async fn main() -> Result<()> {
    use_read().await?;
    use_read_to_end().await?;
    use_write().await?;
    use_write_all().await?;
    use_copy().await?;
    Ok(())
}

async fn use_read() -> Result<()> {
    let mut f = File::open("Cargo.toml").await?;
    let mut buffer = [0; 10];

    let n = f.read(&mut buffer[..]).await?;
    println!("The bytes: {:?}", &buffer[..n]);

    Ok(())
}

async fn use_read_to_end() -> Result<()> {
    let mut f = File::open("Cargo.toml").await?;
    let mut buffer = Vec::new();

    f.read_to_end(&mut buffer).await?;
    println!("all bytes: {:?}", buffer);

    Ok(())
}

async fn use_write() -> Result<()> {
    let mut f = File::create("foo.txt").await?;
    let n = f.write(b"some bytes").await?;
    println!("Wrote the first {} bytes of 'some bytes'.", n);
    Ok(())
}

async fn use_write_all() -> Result<()> {
    let mut f = File::create("foo.txt").await?;
    f.write_all(b"some bytes").await?;
    Ok(())
}

async fn use_copy() -> Result<()> {
    let mut reader: &[u8] = b"hello";
    let mut file = File::create("foo2.txt").await?;

    tokio::io::copy(&mut reader, &mut file).await?;
    Ok(())
}
