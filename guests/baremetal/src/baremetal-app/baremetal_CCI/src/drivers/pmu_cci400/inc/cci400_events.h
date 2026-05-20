#ifndef CCI400_EVENTS_H
#define CCI400_EVENTS_H

#include <stdint.h>

#define CCI_EVENT(ev, code) {ev, code, #ev}

enum cci_events{

  /* Slave Events */

  si_rrq_hs_any,
  si_rrq_hs_device,
  si_rrq_hs_normal_or_nonshareable,
  si_rrq_hs_inner_or_outershareable,
  si_rrq_hs_cache_maintenance,
  si_rrq_hs_mem_barrier,
  si_rrq_hs_sync_barrier,
  si_rrq_hs_dvm_msg,
  si_rrq_hs_dvm_msg_sync,
  si_rrq_stall_tt_full,
  si_r_data_last_hs_snoop,
  si_r_data_stall_rvalids_h_rready_l,
  si_wrq_hs_any,
  si_wrq_hs_device,
  si_wrq_hs_normal_or_nonshareable,
  si_wrq_hs_inner_or_outershare_wback_wclean,
  si_wrq_hs_write_unique,
  si_wrq_hs_write_line_unique,
  si_wrq_hs_evict,
  si_wrq_stall_tt_full,
  si_rrq_stall_slave_id_hazard,

  /* Master Events */

  mi_retry_speculative_fetch,
  mi_stall_cycle_addr_hazard,
  mi_rrq_stall_master_id_hazard,
  mi_rrq_stall_hi_prio_rtq_full,
  mi_rrq_stall_barrier_hazard,
  mi_wrq_stall_barrier_hazard,
  mi_wrq_stall_wtq_full,
  mi_rrq_stall_low_prio_rtq_full,
  mi_rrq_stall_mid_prio_rtq_full,
  mi_rrq_stall_qvn_vn0,
  mi_rrq_stall_qvn_vn1,
  mi_rrq_stall_qvn_vn2,
  mi_rrq_stall_qvn_vn3,
  mi_wrq_stall_qvn_vn0,
  mi_wrq_stall_qvn_vn1,
  mi_wrq_stall_qvn_vn2,
  mi_wrq_stall_qvn_vn3,
  mi_wrq_unique_or_line_unique_addr_hazard,

  /* Fixed counter for CCI cycles */

  cycles,

};

struct cci_event_desc {
  enum cci_events cci_events_name; 
  uint8_t event_code;
  const char *name;
};

static const struct cci_event_desc cci_event_table [] = {

  /* Slave Events */

  CCI_EVENT(si_rrq_hs_any, 0x00),
  CCI_EVENT(si_rrq_hs_device, 0x01),
  CCI_EVENT(si_rrq_hs_normal_or_nonshareable, 0x02),
  CCI_EVENT(si_rrq_hs_inner_or_outershareable, 0x03),
  CCI_EVENT(si_rrq_hs_cache_maintenance, 0x04),
  CCI_EVENT(si_rrq_hs_mem_barrier, 0x05),
  CCI_EVENT(si_rrq_hs_sync_barrier, 0x06),
  CCI_EVENT(si_rrq_hs_dvm_msg, 0x07),
  CCI_EVENT(si_rrq_hs_dvm_msg_sync, 0x08),
  CCI_EVENT(si_rrq_stall_tt_full, 0x09),
  CCI_EVENT(si_r_data_last_hs_snoop, 0x0A),
  CCI_EVENT(si_r_data_stall_rvalids_h_rready_l, 0x0B),
  CCI_EVENT(si_wrq_hs_any, 0x0C),
  CCI_EVENT(si_wrq_hs_device, 0x0D),
  CCI_EVENT(si_wrq_hs_normal_or_nonshareable, 0x0E),
  CCI_EVENT(si_wrq_hs_inner_or_outershare_wback_wclean, 0x0F),
  CCI_EVENT(si_wrq_hs_write_unique, 0x10),
  CCI_EVENT(si_wrq_hs_write_line_unique, 0x11),
  CCI_EVENT(si_wrq_hs_evict, 0x12),
  CCI_EVENT(si_wrq_stall_tt_full, 0x13),
  CCI_EVENT(si_rrq_stall_slave_id_hazard, 0x14),

  /* Master Events */

  CCI_EVENT(mi_retry_speculative_fetch, 0x00),
  CCI_EVENT(mi_stall_cycle_addr_hazard, 0x01),
  CCI_EVENT(mi_rrq_stall_master_id_hazard, 0x02),
  CCI_EVENT(mi_rrq_stall_hi_prio_rtq_full, 0x03),
  CCI_EVENT(mi_rrq_stall_barrier_hazard, 0x04),
  CCI_EVENT(mi_wrq_stall_barrier_hazard, 0x05),
  CCI_EVENT(mi_wrq_stall_wtq_full, 0x06),
  CCI_EVENT(mi_rrq_stall_low_prio_rtq_full, 0x07),
  CCI_EVENT(mi_rrq_stall_mid_prio_rtq_full, 0x08),
  CCI_EVENT(mi_rrq_stall_qvn_vn0, 0x09),
  CCI_EVENT(mi_rrq_stall_qvn_vn1, 0x0A),
  CCI_EVENT(mi_rrq_stall_qvn_vn2, 0x0B),
  CCI_EVENT(mi_rrq_stall_qvn_vn3, 0x0C),
  CCI_EVENT(mi_wrq_stall_qvn_vn0, 0x0D),
  CCI_EVENT(mi_wrq_stall_qvn_vn1, 0x0E),
  CCI_EVENT(mi_wrq_stall_qvn_vn2, 0x0F),
  CCI_EVENT(mi_wrq_stall_qvn_vn3, 0x10),
  CCI_EVENT(mi_wrq_unique_or_line_unique_addr_hazard, 0x11),

  /* Fixed counter for CCI cycles */

  CCI_EVENT(cycles, 0xff),

};


#endif