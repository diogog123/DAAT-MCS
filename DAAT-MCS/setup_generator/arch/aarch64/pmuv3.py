class pmu:
    def __init__(self):
        self.events_list = {
            "sw_incr"                        : 0x00,
            "l1i_cache_reffill"              : 0x01,
            "l1i_tlb_refill"                 : 0x02,
            "l1d_cache_reffill"              : 0x03,
            "l1d_cache"                      : 0x04,
            "l1d_tlb_refill"                 : 0x05,
            "ld_retired"                     : 0x06,
            "st_retired"                     : 0x07,
            "inst_retired"                   : 0x08,
            "exc_taken"                      : 0x09,
            "exc_return"                     : 0x0A,
            "cid_write_retired"              : 0x0B,
            "pc_write_retired"               : 0x0C,
            "br_immed_retired"               : 0x0D,
            "unaligned_ldst_retired"         : 0x0F,
            "br_mis_pred"                    : 0x10,
            "cpu_cycles"                     : 0x11,
            "br_pred"                        : 0x12,
            "mem_access"                     : 0x13,
            "l1i_cache"                      : 0x14,
            "l1d_cache_wb"                   : 0x15,
            "l2d_cache"                      : 0x16,
            "l2d_cache_refill"               : 0x17,
            "l2d_cache_wb"                   : 0x18,
            "bus_access"                     : 0x19,
            "memory_error"                   : 0x1A,
            "bus_cycles"                     : 0x1D,
            "chain"                          : 0x1E,
            "bus_access_ld"                  : 0x60,
            "bus_access_st"                  : 0x61,
            "br_indirect_spec"               : 0x7A,
            "exc_irq"                        : 0x86,
            "exc_fiq"                        : 0x87,
            "ext_mem_req"                    : 0xC0,
            "non_cache_ext_mem_req"          : 0xC1,
            "line_fill_pref"                 : 0xC2,
            "inst_cache_thrott_occ"          : 0xC3,
            "ent_read_alloc_mode"            : 0xC4,
            "read_alloc_mode"                : 0xC5,
            "pre_dec_error"                  : 0xC6,
            "dwr_pipe_stall"                 : 0xC7,
            "scu_dsnoop_cpu"                 : 0xC8,
            "cond_br_exec"                   : 0xC9,
            "ind_br_mispred"                 : 0xCA,
            "ind_br_mispred_addr_miscomp"    : 0xCB,
            "cond_br_mispred"                : 0xCC,
            "l1i_mem_error"                  : 0xD0,
            "l1d_mem_error"                  : 0xD1,
            "tlb_mem_error"                  : 0xD2,
            "attr_perf_counter_impact_ev0"   : 0xE0,
            "attr_perf_counter_impact_ev1"   : 0xE1,
            "attr_perf_counter_impact_ev2"   : 0xE2,
            "attr_perf_counter_impact_ev3"   : 0xE3,
            "attr_perf_counter_impact_ev4"   : 0xE4,
            "attr_perf_counter_impact_ev5"   : 0xE5,
            "attr_perf_counter_impact_ev6"   : 0xE6,
            "attr_perf_counter_impact_ev7"   : 0xE7,
            "attr_perf_counter_impact_ev8"   : 0xE8
        }

    def generate_perf_monitor_code(self, list_events):
        upper_val = 0
        lower_val = 0

        for event in list_events:
            if event not in self.events_list:
                print(f"Event {event} not found")
                continue

            else:
                event_val = self.events_list[event]
                if event_val < 64:
                    lower_val |= 1 << event_val
                else:
                    upper_val |= 1 << (event_val-64)
    
        return f"0x{upper_val:08x}-0x{lower_val:08x}"
