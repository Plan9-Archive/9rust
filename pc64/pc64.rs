#![feature(no_std)]
#![feature(lang_items)]
#![feature(core)]
#![feature(asm)]
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

mod prelude;

#[macro_use]
mod macros;

#[path="../port/mod.rs"]
pub mod port;

#[path="../pc/mod.rs"]
pub mod pc;

#[lang="start"]
#[no_mangle]
pub extern "C" fn main()
{
    let mb = ::pc::multiboot::multibootptr;
	log!("Plan 9");
    log!("multiboot flags = {:032b}", mb.flags);

    if (mb.flags & 1 << 0) != 0 {
        log!("have memory map");
    } else {
        log!("no memory map");
    }

    if (mb.flags & 1 << 1) != 0 {
        let b = mb.boot_device;
        log!("boot device: {} {} {} {}", b[0], b[1], b[2], b[3]);
    } else {
        log!("no boot device");
    }

    log!("cli arguments: {}", cmdline());
    log!("bootloader: {}", bootloader());
}

fn c2str(c_str: *const u8) -> Option<&'static [u8]>
{
    unsafe {
        let mut ptr = c_str;
        while *ptr != 0 {
            ptr = ptr.offset(1);
        }
        Some(::core::mem::transmute(::core::raw::Slice{data: c_str, len: ptr as usize - c_str as usize}))
    }
}

fn bootloader() -> &'static str
{
    let mb = ::pc::multiboot::multibootptr;
    if (mb.flags & 1 << 9) == 0 {
        return "";
    }

    let paddr = mb.boot_loader_name as usize;
    let cptr = (paddr + 0xFFFFFFFF_80000000) as *const u8;

    if let Some(s) = c2str(cptr) {
        ::core::str::from_utf8(s).ok().unwrap_or("invalid")
    } else {
        ""
    }
}

fn cmdline() -> &'static str
{
    let mb = ::pc::multiboot::multibootptr;
    if (mb.flags & 1 << 2) == 0 {
        return "";
    }

    let paddr = mb.cmdline as usize;
    let cptr = (paddr + 0xFFFFFFFF_80000000) as *const u8;

    if let Some(s) = c2str(cptr) {
        ::core::str::from_utf8(s).ok().unwrap_or("invalid")
    } else {
        ""
    }
}

// vim: ft=rust

