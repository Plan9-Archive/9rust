#![feature(no_std)]
#![feature(lang_items)]
#![feature(asm)]
#![feature(core)]
#![no_std]

use prelude::*;

#[macro_use]
extern crate core;

mod std {
	pub use core::fmt;
	pub use core::cmp;
	pub use core::ops;
	pub use core::iter;
	pub use core::option;
	pub use core::marker;
}

#[macro_use]
mod macros;

mod io;
pub mod debug;

mod prelude;
pub mod unwind;

mod logging;

#[lang="start"]
#[no_mangle]
pub extern "C" fn main()
{
	log!("Hello world! 1={}", 1);
}

// vim: ft=rust

