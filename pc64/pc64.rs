//#![crate_type="lib"]
#![feature(no_std)]
#![feature(asm)]
#![feature(core)]
#![feature(lang_items)]
#![no_std]

#[macro_use]
extern crate core;

#[macro_use]
mod macros;

mod io;
pub mod debug;

mod prelude;
pub mod unwind;

mod logging;

#[no_mangle]
pub extern "C" fn main()
{
}

// vim: ft=rust

