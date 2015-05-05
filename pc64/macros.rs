macro_rules! log{
	( $($arg:tt)* ) => ({
		// Import the Writer trait (required by write!)
		use core::fmt::Write;
		let _ = write!(&mut ::port::logging::Writer::get(module_path!()), $($arg)*);
	})
}

