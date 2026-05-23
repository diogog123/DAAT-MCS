set num_runs 101

# ─── Argumentos ───────────────────────────────────────────
# Usage: vivado -mode batch -source getwaves.tcl -tclargs <1|2> <channels> <test_type> <coherency> <output_base> <ltx_file>
if {$argc < 6} {
    puts "\nERROR: Missing arguments"
    puts "Usage: vivado -mode batch -source getwaves.tcl -tclargs <1|2> <channels> <test_type> <coherency> <output_base> <ltx_file>"
    exit 1
}

set test_val    [lindex $argv 0]
set channels    [lindex $argv 1]
set test_type_c [lindex $argv 2]
set coherency   [lindex $argv 3]
set output_base [lindex $argv 4]
set ltx_file    [lindex $argv 5]

# ─── Snoop type ───────────────────────────────────────────
switch $test_val {
    1 {
        set trigger_probe "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_arvalid_1"
        set test_type "RS"
        set test_name "Read Snoop"
    }
    2 {
        set trigger_probe "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_awvalid_1"
        set test_type "WS"
        set test_name "Write Snoop"
    }
    default {
        puts "ERROR: Invalid option $test_val"
        exit 1
    }
}

# ─── Output dir ───────────────────────────────────────────
set output_dir "${output_base}"

proc run_test {trigger_probe test_type test_name num_runs output_dir} {
    puts "\n========================================="
    puts "Test: $test_name ($test_type)"
    puts "Runs: $num_runs"
    puts "Output: $output_dir"
    puts "========================================="
    file mkdir $output_dir
    set ila   [lindex [get_hw_ilas] 0]
    set probe [get_hw_probes $trigger_probe]
    set_property TRIGGER_COMPARE_VALUE eq1'bR $probe
    puts "\nStarting captures...\n"
    for {set run 1} {$run <= $num_runs} {incr run} {
        puts "$run/$num_runs Arming ILA..."
        run_hw_ila $ila
        wait_on_hw_ila $ila
        puts "Trigger detected!"
        set ila_data    [upload_hw_ila_data $ila]
        set output_file "${output_dir}/${test_type}_capture_run${run}.csv"
        write_hw_ila_data -csv_file $output_file $ila_data
        puts "Saved: $output_file"
        after 300
    }
    puts "\n✓ $test_name completed"
}

puts "\nConnecting to hardware..."
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target [lindex [get_hw_targets] 0]

set dev [lindex [get_hw_devices] 0]
set_property PROBES.FILE $ltx_file $dev
refresh_hw_device $dev

puts "\nAvailable probes:"
puts [get_hw_probes]

run_test \
    $trigger_probe \
    $test_type \
    $test_name \
    $num_runs \
    $output_dir

puts "\n========================================="
puts "TEST COMPLETED"
puts "========================================="
