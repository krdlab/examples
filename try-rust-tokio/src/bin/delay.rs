use std::sync::{Arc, Mutex};
use std::task::{Context, Poll, Waker};
use std::time::{Duration, Instant};
use std::{future::Future, pin::Pin, thread};

struct Delay {
    when: Instant,
    waker: Option<Arc<Mutex<Waker>>>,
}

impl Future for Delay {
    type Output = ();

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> std::task::Poll<Self::Output> {
        if let Some(waker) = &self.waker {
            let mut waker = waker.lock().unwrap();
            if !waker.will_wake(cx.waker()) {
                *waker = cx.waker().clone();
            }
        } else {
            let when = self.when;
            let waker = Arc::new(Mutex::new(cx.waker().clone()));
            self.waker = Some(waker.clone());
            thread::spawn(move || {
                let now = Instant::now();
                if now < when {
                    thread::sleep(when - now);
                }
                let waker = waker.lock().unwrap();
                waker.wake_by_ref();
            });
        }

        if Instant::now() >= self.when {
            Poll::Ready(())
        } else {
            Poll::Pending
        }
    }
}

#[tokio::main]
async fn main() {
    let when1 = Instant::now() + Duration::from_secs(3);
    let future1 = Delay {
        when: when1,
        waker: None,
    };
    let when2 = Instant::now() + Duration::from_secs(5);
    let future2 = Delay {
        when: when2,
        waker: None,
    };

    let begin = Instant::now();
    println!("begin");
    let _ = future1.await;
    println!("end: interval = {:?}", Instant::now() - begin);
    let _ = future2.await;
    println!("end: interval = {:?}", Instant::now() - begin);
    println!("done");
}
