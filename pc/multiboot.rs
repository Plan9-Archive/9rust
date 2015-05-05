#[repr(C)]
pub struct Multiboot
{
    pub flags: u32,
    pub mem_lower: u32,
    pub mem_higher: u32,
    pub boot_device: [u8; 4],
    pub cmdline: u32,
    pub mods_count: u32,
    pub mods_addr: u32,
    pub syms: [u32; 4],
    pub mmap_length: u32,
    pub mmap_addr: u32,
    pub drives_length: u32,
    pub drives_addr: u32,
    pub config_table: u32,
    pub boot_loader_name: u32,
    pub apm_table: u32,
    pub vbe_control_info: u32,
    pub vbe_mode_info: u32,
    pub vbe_mode: u32,
    pub vbe_interface_seg: u32,
    pub vbe_interface_off: u32,
    pub vbe_interface_len: u32,
}

extern "C"
{
    pub static multibootsig : u32;
    pub static multibootptr : &'static Multiboot;
}

