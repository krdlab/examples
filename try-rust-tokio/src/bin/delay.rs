use std::{future::Future, task::Poll, time::{Instant, Duration}};

struct Delay {
    when: Instant,
}

impl Future for Delay {
    type Output = &'static str;

    fn poll(
        self: std::pin::Pin<&mut Self>,
        cx: &mut std::task::Context<'_>,
    ) -> std::task::Poll<Self::Output> {
        if Instant::now() >= self.when {
            println!("Hello world");
            Poll::Ready("done")
        } else {
            cx.waker().wake_by_ref();
            Poll::Pending
        }
    }
}

#[tokio::main]
async fn main() {
  let when = Instant::now() + Duration::from_secs(3);
  let future = Delay { when };

  println!("{:?}", Instant::now());
  let out = future.await;
  println!("{:?}", Instant::now());
  assert_eq!(out, "done");
}
