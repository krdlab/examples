#![no_std]

use wio_terminal as wio;

pub use wio::entry;
pub use embedded_hal::blocking::delay::DelayMs;

use wio::hal::clock::GenericClockController;
use wio::hal::delay::Delay;
use wio::hal::gpio::{Port, Pa15, Input, Floating, Output, PushPull};
use wio::pac::{CorePeripherals, Peripherals};
use wio::prelude::*;

/// LEDドライバ
pub struct Led {
    pin: Pa15<Output<PushPull>>,
}

impl Led {
    fn new(pin: Pa15<Input<Floating>>, port: &mut Port) -> Led {
        Led {
            pin: pin.into_push_pull_output(port),
        }
    }

    /// LEDを点灯する
    pub fn turn_on(&mut self) {
        self.pin.set_high().unwrap();
    }

    /// LEDを消灯する
    pub fn turn_off(&mut self) {
        self.pin.set_low().unwrap();
    }

    /// LEDが点灯していれば消灯し、消灯していれば点灯する
    pub fn toggle(&mut self) {
        self.pin.toggle();
    }
}

pub fn init() -> (Led, Delay) {
    let mut peripherals = Peripherals::take().unwrap();
    let core = CorePeripherals::take().unwrap();
    let mut clocks = GenericClockController::with_external_32kosc(
        peripherals.GCLK,
        &mut peripherals.MCLK,
        &mut peripherals.OSC32KCTRL,
        &mut peripherals.OSCCTRL,
        &mut peripherals.NVMCTRL,
    );

    let mut pins = wio::Pins::new(peripherals.PORT);
    let led = Led::new(pins.user_led, &mut pins.port);
    let delay = Delay::new(core.SYST, &mut clocks);

    (led, delay)
}
