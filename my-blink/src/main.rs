#![no_std]
#![no_main]

use panic_halt as _;
use support::*;

#[entry]
fn main() -> ! {
    let (mut user_led, mut delay) = support::init();

    loop {
        delay.delay_ms(500u16);
        user_led.toggle();
    }
}
