# # Fixed boot root path
# set boot_root_path "/media/diogo/rootfs/CCI_Interference/platform/firmware/soc-prebuilt-firmware/zcu104-zynqmp_bfx"

# # Default bitstream (optional fallback)
# set bitstream_path ""

# # Get bitstream from XSCT argument
# if {[llength $argv] >= 1} {
#     set bitstream_path [lindex $argv 0]
# }

# # Connect
# connect

# # Disable security gates
# targets -set -nocase -filter {name =~ "*PSU*"}
# rst -system
# mask_write 0xFFCA0038 0x1C0 0x1C0

# # Load FPGA bitstream if provided
# if {$bitstream_path ne ""} {
#     puts "Loading bitstream: $bitstream_path"
#     fpga $bitstream_path
# } else {
#     puts "ERROR: No bitstream provided"
#     exit 1
# }

# # PMU FW
# targets -set -nocase -filter {name =~ "*MicroBlaze PMU*"}
# dow $boot_root_path/pmufw.elf
# con
# after 500

# # FSBL
# targets -set -nocase -filter {name =~ "*A53*#0"}
# rst -proc
# dow $boot_root_path/executable.elf
# con
# after 500
# stop

# # DTB
# dow -data $boot_root_path/system.dtb 0x100000
# after 500

# # U-Boot
# dow $boot_root_path/u-boot.elf
# dow $boot_root_path/bl31.elf
# con

# Fixed boot root path
set boot_root_path "/media/diogo/rootfs/CCI_Interference/platform/firmware/soc-prebuilt-firmware/zcu104-zynqmp_bfx"

set bitstream_path ""

if {[llength $argv] >= 1} {
    set bitstream_path [lindex $argv 0]
}

catch {disconnect}
after 1000

connect
after 500

# Um único rst -system no início
targets -set -nocase -filter {name =~ "*PSU*"}
rst -system
after 2000
mask_write 0xFFCA0038 0x1C0 0x1C0
after 500

if {$bitstream_path ne ""} {
    puts "Loading bitstream: $bitstream_path"
    fpga $bitstream_path
    after 500
} else {
    puts "ERROR: No bitstream provided"
    exit 1
}

# PMU FW
targets -set -nocase -filter {name =~ "*MicroBlaze PMU*"}
dow $boot_root_path/pmufw.elf
con
after 500

# FSBL
targets -set -nocase -filter {name =~ "*A53*#0"}
rst -proc
dow $boot_root_path/executable.elf
con
after 500
stop

# DTB
dow -data $boot_root_path/system.dtb 0x100000
after 500

# U-Boot + BL31
dow $boot_root_path/u-boot.elf
dow $boot_root_path/bl31.elf
con

puts "Flash completed successfully"