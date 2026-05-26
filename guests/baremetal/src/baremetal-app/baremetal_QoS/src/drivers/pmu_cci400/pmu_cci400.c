#include <stdio.h>
#include <stdint.h>
#include "pmu_cci400.h"
#include "cci400_events.h"

#define CCI_MAX_COUNTERS            4

volatile struct cci_regs_t *p_cci_regs = (volatile struct cci_regs_t*)CCI_BASE_ADDRESS;

void enable_allcounters(){

  WRITE_BIT(p_cci_regs->performance_monitor_control_register,CEN_BIT,1);

}

void disable_allcounters(){

  WRITE_BIT(p_cci_regs->performance_monitor_control_register,CEN_BIT,0);

}

void reset_allcounters(){

  WRITE_BIT(p_cci_regs->performance_monitor_control_register,RST_BIT,1);
  WRITE_BIT(p_cci_regs->performance_monitor_control_register,RST_BIT,0);

}

void cycle_counter_enable(){

  cycle_counter_reset();
  WRITE_BIT(p_cci_regs->cycle_counter_control,CCNT_EN_BIT,1);

}

void cycle_counter_disable(){

  WRITE_BIT(p_cci_regs->performance_monitor_control_register,CCR_BIT,0);

}

void cycle_counter_reset(){

  WRITE_BIT(p_cci_regs->performance_monitor_control_register,CCR_BIT,1);
  WRITE_BIT(p_cci_regs->performance_monitor_control_register,CCR_BIT,0);

}

uint32_t cycle_counter_get(){

  return p_cci_regs->cycle_counter;

}

void cci_pmu_start(){

  reset_allcounters();
  enable_allcounters();

}

int cci_setup_counters(const struct cci_counters_cfg *cfg, size_t num_counters){

  uint8_t event_code = 0;
  uint8_t interface = 0;
  uint8_t counter = 0; 

  if (cci_validate_config(cfg, num_counters) != 0) {
    printf("CCI PMU setup aborted due to invalid configuration\n");
    return -1;
  }

  if(num_counters > 4){
    printf("\nYou exceed the number of counters!\n");
    return COUNTERS_ERROR;
  }
  for(size_t i = 0; i < num_counters; i++){

    event_code = cci_event_to_hwcode(cfg[i].events);
    interface = cfg[i].interface;
    counter = cfg[i].counter;
    
    switch(counter){
      case 0: /* Counter 0 */
        WRITE_FIELD(p_cci_regs->esr0,EVT_CNT0_MASK,EVT_CNT0_SHIFT,event_code);
        WRITE_FIELD(p_cci_regs->esr0,EVT_IF0_MASK,EVT_IF0_SHIFT,interface);
        WRITE_BIT(p_cci_regs->event_counter0_control,CNT0_EN_BIT,1);
      break;  
      case 1: /* Counter 1 */
        WRITE_FIELD(p_cci_regs->esr1,EVT_CNT1_MASK,EVT_CNT1_SHIFT,event_code);
        WRITE_FIELD(p_cci_regs->esr1,EVT_IF1_MASK,EVT_IF1_SHIFT,interface);
        WRITE_BIT(p_cci_regs->event_counter1_control,CNT1_EN_BIT,1);
      break;
      case 2: /* Counter 2 */
        WRITE_FIELD(p_cci_regs->esr2,EVT_CNT2_MASK,EVT_CNT2_SHIFT,event_code);
        WRITE_FIELD(p_cci_regs->esr2,EVT_IF2_MASK,EVT_IF2_SHIFT,interface);
        WRITE_BIT(p_cci_regs->event_counter2_control,CNT2_EN_BIT,1);
      break;
      case 3: /* Counter 3 */
        WRITE_FIELD(p_cci_regs->esr3,EVT_CNT3_MASK,EVT_CNT3_SHIFT,event_code);
        WRITE_FIELD(p_cci_regs->esr3,EVT_IF2_MASK,EVT_IF2_SHIFT,interface);
        WRITE_BIT(p_cci_regs->event_counter3_control,CNT3_EN_BIT,1);
      break;
    }
  }
}

uint32_t pmu_cci_counter_get(uint8_t counter){

  switch(counter){
    case 0 : return p_cci_regs->event_counter0;
    case 1 : return p_cci_regs->event_counter1;
    case 2 : return p_cci_regs->event_counter2;
    case 3 : return p_cci_regs->event_counter3;
    default:
      printf("We only had 4 counters (0-3)!\n");
  }
}

int cci_validate_config(const struct cci_counters_cfg *cfg, size_t num_events){

    uint8_t used_counters_mask = 0;

    if(num_events == 0 || num_events > CCI_MAX_COUNTERS){
        printf("CCI config error: invalid number of events (%zu)\n", num_events);
        return -1;
    }

    for(size_t i = 0; i < num_events; i++){

        if(cfg[i].counter >= CCI_MAX_COUNTERS){
          printf("CCI config error: counter %u out of range (event %zu)\n",
                   cfg[i].counter, i);
          return -1;
        }
          
        if(used_counters_mask & (1U << cfg[i].counter)) {
            printf("CCI config error: counter %u used more than once\n",
                    cfg[i].counter);
            return -1;
        }
        used_counters_mask |= (1U << cfg[i].counter);
        
        for (size_t j = i + 1; j < num_events; j++) {
          if (cfg[i].events == cfg[j].events && cfg[i].interface == cfg[j].interface || cfg[i].events == cfg[j].events && cfg[i].counter == cfg[j].counter) {
              printf("CCI config error: event %s configured twice\n",
                     cci_getevent(cfg[i].events));
              return -1;
          }
       }
    }
    return 0;
}
