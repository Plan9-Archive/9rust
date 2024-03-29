use prelude::*;

/// Write a string to the output channel
///
/// This method is unsafe because it does port accesses without synchronisation
pub unsafe fn puts(s: &str)
{
	for b in s.bytes()
	{
		putb(b);
	}
}

/// Write a single byte to the output channel
///
/// This method is unsafe because it does port accesses without synchronisation
pub unsafe fn putb(b: u8)
{
	// Wait for the serial port's fifo to not be empty
	while (::pc::io::inb(0x3F8+5) & 0x20) == 0
	{
		// Do nothing
	}
	// Send the byte out the serial port
	::pc::io::outb(0x3F8, b);
	
	// Also send to the bochs 0xe9 hack
	::pc::io::outb(0xe9, b);
}
