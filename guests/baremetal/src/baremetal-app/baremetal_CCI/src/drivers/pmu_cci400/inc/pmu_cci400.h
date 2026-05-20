#ifndef PMU_CCI400_H
#define PMU_CCI400_H

#include "cci400_events.h"
#include <stdint.h>

#define CCI_BASE_ADDRESS          0xFD6E0000

struct cci_regs_t {                                       /* offsets */

  uint32_t control_override_register;                   /* 0x0000000000 */ /* we cant access this one because is full secure */
  uint32_t speculation_control_register;                /* 0x0000000004 */
  uint32_t secure_access_register;                      /* 0x0000000008 */
  uint32_t status_register;                             /* 0x000000000C */
  uint32_t imprecise_error_register;                    /* 0x0000000010 */
  uint8_t reserved1 [0x0000000100 - 0x0000000014];       
  uint32_t performance_monitor_control_register;        /* 0x0000000100 */
  uint8_t reserved2 [0x0000001000 - 0x0000000104];
  uint32_t snoop_control_register_S0;                   /* 0x0000001000 */
  uint32_t shareable_override_register_S0;              /* 0x0000001004 */
  uint8_t reserved3 [0x0000001100 - 0x0000001008];
  uint32_t read_Qos_override_register_S0;               /* 0x0000001100 */
  uint32_t write_Qos_override_register_S0;              /* 0x0000001104 */
  uint8_t reserved4 [0x000000110C - 0x0000001108];
  uint32_t Qos_control_register_S0;                     /* 0x000000110C */
  uint32_t max_ot_register_S0;                          /* 0x0000001110 */ 
  uint8_t reserved5 [0x0000001130 - 0x0000001114];
  uint32_t target_latency_register_S0;                  /* 0x0000001130 */
  uint32_t latency_regulation_register_S0;              /* 0x0000001134 */
  uint32_t Qos_range_register_S0;                       /* 0x0000001138 */
  uint8_t reserved6 [0x0000002000 - 0x000000113C];
  uint32_t snoop_control_register_S1;                   /* 0x0000002000 */
  uint32_t shareable_override_register_S1;              /* 0x0000002004 */
  uint8_t reserved7 [0x0000002100 - 0x0000002008];
  uint32_t read_Qos_override_register_S1;               /* 0x0000002100 */
  uint32_t write_Qos_override_register_S1;              /* 0x0000002104 */
  uint8_t reserved8 [0x000000210C - 0x0000002108];
  uint32_t Qos_control_register_S1;                     /* 0x000000210C */
  uint32_t max_ot_register_S1;                          /* 0x0000002110 */ 
  uint8_t reserved9 [0x0000002130 - 0x0000002114];
  uint32_t target_latency_register_S1;                  /* 0x0000002130 */
  uint32_t latency_regulation_register_S1;              /* 0x0000002134 */
  uint32_t Qos_range_register_S1;                       /* 0x0000002138 */
  uint8_t reserved10 [0x0000003000 - 0x000000213C];
  uint32_t snoop_control_register_S2;                   /* 0x0000003000 */
  uint32_t shareable_override_register_S2;              /* 0x0000003004 */
  uint8_t reserved11 [0x0000003100 - 0x0000003008];
  uint32_t read_Qos_override_register_S2;               /* 0x0000003100 */
  uint32_t write_Qos_override_register_S2;              /* 0x0000003104 */
  uint8_t reserved12 [0x000000310C - 0x0000003108];
  uint32_t Qos_control_register_S2;                     /* 0x000000310C */
  uint32_t max_ot_register_S2;                          /* 0x0000003110 */ 
  uint8_t reserved13 [0x0000003130 - 0x0000003114];
  uint32_t target_latency_register_S2;                  /* 0x0000003130 */
  uint32_t latency_regulation_register_S2;              /* 0x0000003134 */
  uint32_t Qos_range_register_S2;                       /* 0x0000003138 */
  uint8_t reserved14 [0x0000004000 - 0x000000313C];
  uint32_t snoop_control_register_S3;                   /* 0x0000004000 */
  uint8_t reserved15 [0x0000004100 - 0x0000004004];
  uint32_t read_Qos_override_register_S3;               /* 0x0000004100 */
  uint32_t write_Qos_override_register_S3;              /* 0x0000004104 */
  uint8_t reserved16 [0x000000410C - 0x0000004108];     
  uint32_t Qos_control_register_S3;                     /* 0x000000410C */
  uint8_t reserverd17 [0x0000004130 - 0x0000004110];
  uint32_t target_latency_register_S3;                  /* 0x0000004130 */
  uint32_t latency_regulation_register_S3;              /* 0x0000004134 */
  uint32_t Qos_range_register_S3;                       /* 0x0000004138 */
  uint8_t reserved18 [0x0000005000 - 0x000000413C];
  uint32_t snoop_control_register_S4;                   /* 0x0000005000 */
  uint8_t reserved19 [0x0000005100 - 0x0000005004];
  uint32_t read_Qos_override_register_S4;               /* 0x0000005100 */
  uint32_t write_Qos_override_register_S4;              /* 0x0000005104 */
  uint8_t reserved20 [0x000000510C - 0x0000005108];
  uint32_t Qos_control_register_S4;                     /* 0x000000510C */
  uint8_t reserverd21 [0x0000005130 - 0x0000005110];
  uint32_t target_latency_register_S4;                  /* 0x0000005130 */
  uint32_t latency_regulation_register_S4;              /* 0x0000005134 */
  uint32_t Qos_range_register_S4;                       /* 0x0000005138 */
  uint8_t reserved22 [0x0000009004 - 0x000000513C];
  uint32_t cycle_counter;                               /* 0x0000009004 */
  uint32_t cycle_counter_control;                       /* 0x0000009008 */
  uint32_t cycle_count_overflow;                        /* 0x000000900C */
  uint8_t reserved23 [0x000000A000 - 0x0000009010];
  uint32_t esr0;                                        /* 0x000000A000 */
  uint32_t event_counter0;                              /* 0x000000A004 */
  uint32_t event_counter0_control;                      /* 0x000000A008 */
  uint32_t event_counter0_overflow;                     /* 0x000000A00C */
  uint8_t reserved24 [0x000000B000 - 0x000000A010];
  uint32_t esr1;                                        /* 0x000000B000 */
  uint32_t event_counter1;                              /* 0x000000B004 */
  uint32_t event_counter1_control;                      /* 0x000000B008 */
  uint32_t event_counter1_overflow;                     /* 0x000000B00C */
  uint8_t reserved25 [0x000000C000 - 0x000000B010];
  uint32_t esr2;                                        /* 0x000000C000 */
  uint32_t event_counter2;                              /* 0x000000C004 */
  uint32_t event_counter2_control;                      /* 0x000000C008 */
  uint32_t event_counter2_overflow;                     /* 0x000000C00C */
  uint8_t reserved26 [0x000000D000 - 0x000000C010];
  uint32_t esr3;                                        /* 0x000000D000 */
  uint32_t event_counter3;                              /* 0x000000D004 */
  uint32_t event_counter3_control;                      /* 0x000000D008 */
  uint32_t event_counter3_overflow;                     /* 0x000000D00C */
};

#define COUNTERS_ERROR                     -1
 
/* Control Override Register */

#define SNOOP_DISABLE_BIT                  0  /* disable all snoops (not DVM messages) */
#define DVM_MESSAGE_DISABLE_BIT            1  /* disable propagation of all DVM messages */
#define DISABLE_SPECULATIVE_FETCHES_BIT    2  /* disable speculative fetches from all master interfaces */
#define TERMINATE_BARRIERS_BIT             3  /* all master interfaces terminate barriers */
#define DISABLE_PRIORITY_PROMOTION_BIT     4  /* ARQOSARBS inputs are ignored */
#define DISABLE_RETRY_REDUC_BUFFERS_BIT    5  /* disable the retry reduction buffers in all master interfaces */

/* Speculation Control Register */

#define DISABLE_SPEC_FETCHES_M0_BIT       0   /* Disable speculative fetches from master interface M0 */
#define DISABLE_SPEC_FETCHES_M1_BIT       1   /* Disable speculative fetches from master interface M1 */
#define DISABLE_SPEC_FETCHES_M2_BIT       2   /* Disable speculative fetches from master interface M2 */
#define DISABLE_SPEC_FETCHES_S0_BIT       16  /* Disable speculative fetches from master interface S0 */
#define DISABLE_SPEC_FETCHES_S1_BIT       17  /* Disable speculative fetches from master interface S1 */
#define DISABLE_SPEC_FETCHES_S2_BIT       18  /* Disable speculative fetches from master interface S2 */
#define DISABLE_SPEC_FETCHES_S3_BIT       19  /* Disable speculative fetches from master interface S3 */
#define DISABLE_SPEC_FETCHES_S4_BIT       20  /* Disable speculative fetches from master interface S4 */

/* Secure Access Register */

#define SECURE_ACCESS_CONTROL_BIT         0   /* Enable non-secure access to CCI-400 registers */

/* Status Register */

#define CCI_STATUS_BIT                    0   /* Indicates whether any changes to the snoop or DVM enables is pending in the CCI-400 (read-only) */

/* Imprecise Error Register */

#define IMP_ERR_M0                        0   /* Imprecise error indicator for master interface M0. Write 1 to clear */
#define IMP_ERR_M1                        1   /* Imprecise error indicator for master interface M1. Write 1 to clear */
#define IMP_ERR_M2                        2   /* Imprecise error indicator for master interface M2. Write 1 to clear */
#define IMP_ERR_S0                        16  /* Imprecise error indicator for master interface S0. Write 1 to clear */
#define IMP_ERR_S1                        17  /* Imprecise error indicator for master interface S1. Write 1 to clear */
#define IMP_ERR_S2                        18  /* Imprecise error indicator for master interface S2. Write 1 to clear */
#define IMP_ERR_S3                        19  /* Imprecise error indicator for master interface S3. Write 1 to clear */
#define IMP_ERR_S4                        20  /* Imprecise error indicator for master interface S4. Write 1 to clear */

/* Performance Monitor Control Register */
  
#define CEN_BIT                            0   /* Enable all counters */
#define RST_BIT                            1   /* Reset all performance counters, not including CCNT */
#define CCR_BIT                            2   /* Reset cycle counter */
#define CCD_BIT                            3   /* Cycle count divider(cycle counter velocity, 0 -- count at each cycle; 1 -- count in 64 to 64 cycles) */
#define EX_BIT                             4   /* Export the events to an external pin */
#define DP_BIT                             5   /* Disables cycle counter, CCNT, if non-invasive debug is prohibited */
#define PMU_COUNT_NUM_SHIFT                11  /* Number of PMU counters available (read-only) */  
#define PMU_COUNT_NUM_MASK                 (0x1F << PMU_COUNT_NUM_SHIFT)   

/* Snoop Control Register S0 */

#define ENABLE_DVMs_BIT                    1   /* Enable issuing of DVM message requests from slave interface S0 */
#define SUPPORT_SNOOPS_BIT                 30  /* Slave interface supports snoops (read-only) */
#define SUPPORT_DVMs_BIT                   31  /* Slave interface supports DVM messages (read-only) */

/* Shareable Override Register S0/S1/S2 */

#define AXDOMAIN_OVERRIDE_SHIFT            0   /* AxDOMAIN override for slave interface S0/S1/S2 */
#define AXDOMAIN_OVERRIDE_MASK             (0x3 << AXDOMAIN_OVERRIDE_SHIFT)

/* Read QoS Override Register S0/S1/S2/S3/S4 */

#define ARQOS_VALUE_SHIFT                  0   /* ARQOS value override for slave interface S0/S1/S2/S3/S4 */
#define ARQOS_VALUE_MASK                   (0xF << ARQOS_VALUE_SHIFT)  
#define ARQOS_OVERRIDE_REGISTER_SHIFT      8   /* Reads the ARQOS override value of slave interface S0/S1/S2/S3/S4 (read-only) */
#define ARQOS_OVERRIDE_REGISTER_MASK       (0xF << ARQOS_OVERRIDE_REGISTER_SHIFT)   

/* Write QoS Override Register S0/S1/S2/S3/S4 */

#define AWQOS_VALUE_SHIFT                  0   /* AWQOS value override for slave interface S0/S1/S2/S3/S4 */
#define AWQOS_VALUE_MASK                   (0xF << AWQOS_VALUE_SHIFT)
#define AWQOS_OVERRIDE_READBACK_SHIFT      8   /* Reads the AWQOS override value of slave interface S0/S1/S2/S3/S4 (read-only) */
#define AWQOS_OVERRIDE_READBACK_MASK       (0xF << AWQOS_OVERRIDE_READBACK_SHIFT)

/* QoS Control Register S0/S1/S2 */

#define AWQOS_REGULATION_BIT               0   /* Enable QoS value regulation on writes for slave interface S0/S1/S2 */
#define ARQOS_REGULATION_BIT               1   /* Enable QoS value regulation on reads for slave interface S0/S1/S2 */
#define AW_OT_REGULATION_BIT               2   /* Enable regulation of outstanding write transactions for slave interface S0/S1/S2 */
#define AR_OT_REGULATION_BIT               3   /* Enable regulation of outstanding read transactions for slave interface S0/S1/S2 */
#define AWQOS_REGULATION_MODE_BIT          16  /* Select between bandwidth or latency mode of AWQOS regulation for slave interface S0/S1/S2 */
#define ARQOS_REGULATION_MODE_BIT          20  /*	Select between bandwidth or latency mode of ARQOS regulation for slave interface S0/S1/S2 */
#define BANDWIDTH_REGULATION_MODE_BIT      21  /* Select between normal or quiesce high mode of bandwidth regulation for slave interface S0/S1/S2 */
#define QOS_REGULATION_DISABLED_BIT        31  /* High if QoS regulation is disabled in slave interface S0/S1/S2 (read-only) */

/* Max OT Register S0/S1/S2 */

#define FRAC_OT_AW_SHIFT                   0   /* Fractional part of the maximum outstanding AW addresses S0/S1/S2 */
#define FRAC_OT_AW_MASK                    (0xFFu << FRAC_OT_AW_SHIFT)       
#define INT_OT_AW_SHIFT                    8   /* Integer part of the maximum outstanding AW addresses S0/S1/S2 */
#define INT_OT_AW_MASK                     (0x3F << INT_OT_AW_SHIFT)
#define FRAC_OT_AR_SHIFT                   16  /* Fractional part of the maximum outstanding AR addresses S0/S1/S2 */
#define FRAC_OT_AR_MASK                    (0xFFu << FRAC_OT_AR_SHIFT)
#define INT_OR_AR_SHIFT                    24  /* Integer part of the maximum outstanding AR addresses S0/S1/S2 */
#define INT_OR_AR_MASK                     (0x3F << INT_OR_AR_SHIFT)

/* Target Latency Register S0/S1/S2/S3/S4 */

#define AW_LAT_SHIFT                       0   /* AW channel target latency S0/S1/S2/S3/S4 */
#define AW_LAT_MASK                        (0xFFF << AW_LAT_SHIFT)
#define AR_LAT_SHIFT                       16  /* AR channel target latency S0/S1/S2/S3/S4 */
#define AR_LAT_MASK                        (0xFFF << AR_LAT_SHIFT)

/* Latency Regulation Register S0/S1/S2/S3/S4 */

#define AW_SCALE_FACT_SHIFT                0   /* AWQOS scale factor, power of 2 S0/S1/S2/S3/S4 */
#define AW_SCALE_FACT_MASK                 (0x7 << AW_SCALE_FACT_SHIFT)
#define AR_SCALE_FACT_SHIFT                8   /* ARQOS scale factor, power of 2 S0/S1/S2/S3/S4 */
#define AR_SCALE_FACT_MASK                 (0x7 << AR_SCALE_FACT_SHIFT)

/* QoS Range Register S0/S1/S2/S3/S4 */

#define MIN_AWQOS_SHIFT                    0   /* Minimum AWQOS value S0/S1/S2/S3/S4 */           
#define MIN_AWQOS_MASK                     (0xF << MIN_AWQOS_SHIFT)
#define MAX_AWQOS_SHIFT                    8   /* Minimum AWQOS value S0/S1/S2/S3/S4 */
#define MAX_AWQOS_MASK                     (0xF << MAX_AWQOS_SHIFT) 
#define MIN_ARQOS_SHIFT                    16  /* Minimum ARQOS value S0/S1/S2/S3/S4 */
#define MIN_ARQOS_MASK                     (0xF << MIN_ARQOS_SHIFT)
#define MAX_ARQOS_SHIFT                    24  /* Maximum ARQOS value S0/S1/S2/S3/S4 */
#define MAX_ARQOS_MASK                     (0xF << MAX_ARQOS_SHIFT)

/* Snoop Control Register S1/S2 */

#define ENABLE_DVMs_BIT                    1   /* Enable issuing of DVM message requests from slave interface S1/S2 (read-only) */
#define SUPPORT_SNOOPS_BIT                 30  /* Slave interface supports snoops (read-only) */
#define SUPPORT_DVMs_BIT                   31  /* Slave interface supports DVM messages (read-only) */

/* Snoop Control Register S3/S4 */

#define ENABLE_SNOOPS_BIT                  0   /* Enable issuing of snoop requests from slave interface S3/S4 */
#define ENABLE_DVMs_BIT                    1   /* Enable issuing of DVM message requests from slave interface S3/S4 */
#define SUPPORT_SNOOPS_BIT                 30  /* Slave interface supports snoops (read-only) */
#define SUPPORT_DVMs_BIT                   31  /* Slave interface supports DVM messages (read-only) */

/* QoS Control Register S3/S4 */

#define AWQOS_REGULATION_BIT               0   /* Enable QoS value regulation on writes for slave interface S3/S4 */
#define ARQOS_REGULATION_BIT               1   /* Enable QoS value regulation on reads for slave interface S3/S4 */
#define AWQOS_REGULATION_MODE_BIT          16  /* Select between bandwidth or latency mode of AWQOS regulation for slave interface S3/S4 */
#define ARQOS_REGULATION_MODE_BIT          20  /*	Select between bandwidth or latency mode of ARQOS regulation for slave interface S3/S4 */
#define BANDWIDTH_REGULATION_MODE_BIT      21  /* Select between normal or quiesce high mode of bandwidth regulation for slave interface S3/S4 */
#define QOS_REGULATION_DISABLED_BIT        31  /* High if QoS regulation is disabled in slave interface S3/S4 (read-only) */

/* Cycle Counter Control */

#define CCNT_EN_BIT                        0   /* Enable clock cycle counter */

/* Cycle Counter Overflow */

#define CCNT_OVERFLOW_BIT                  0   /* Clock cycle counter overflow flag (Readable, write a 1 to clear	) */

/* Esr0 */

#define EVT_CNT0_SHIFT                     0  /* Event number for counter 0 */
#define EVT_CNT0_MASK                      (0x1F << EVT_CNT0_SHIFT)   
#define EVT_IF0_SHIFT                      5  /* Event interface number for counter 0 */
#define EVT_IF0_MASK                       (0x7 << EVT_IF0_SHIFT)

/* Event Counter0 Control */

#define CNT0_EN_BIT                        0   /* Enable event counter 0 */

/* Event Counter0 Overflow */           

#define CNT0_OVERFLOW_BIT                  0   /* Event counter 0 overflow flag */

/* Esr1 */

#define EVT_CNT1_SHIFT                     0  /* Event number for counter 1 */
#define EVT_CNT1_MASK                      (0x1F << EVT_CNT1_SHIFT)   
#define EVT_IF1_SHIFT                      5  /* Event interface number for counter 1 */
#define EVT_IF1_MASK                       (0x7 << EVT_IF1_SHIFT)

/* Event Counter1 Control */

#define CNT1_EN_BIT                        0   /* Enable event counter 1 */

/* Event Counter1 Overflow */           

#define CNT1_OVERFLOW_BIT                  0   /* Event counter 1 overflow flag */

/* Esr2 */

#define EVT_CNT2_SHIFT                     0  /* Event number for counter 2 */
#define EVT_CNT2_MASK                      (0x1F << EVT_CNT2_SHIFT)   
#define EVT_IF2_SHIFT                      5  /* Event interface number for counter 2 */
#define EVT_IF2_MASK                       (0x7 << EVT_IF2_SHIFT)

/* Event Counter2 Control */

#define CNT2_EN_BIT                        0   /* Enable event counter 2 */

/* Event Counter2 Overflow */           

#define CNT2_OVERFLOW_BIT                  0   /* Event counter 2 overflow flag */

/* Esr3 */

#define EVT_CNT3_SHIFT                     0  /* Event number for counter 3 */
#define EVT_CNT3_MASK                      (0x1F << EVT_CNT3_SHIFT)   
#define EVT_IF3_SHIFT                      5  /* Event interface number for counter 3 */
#define EVT_IF3_MASK                       (0x7 << EVT_IF3_SHIFT)

/* Event Counter3 Control */

#define CNT3_EN_BIT                        0   /* Enable event counter 3 */

/* Event Counter3 Overflow */           

#define CNT3_OVERFLOW_BIT                  0   /* Event counter 3 overflow flag */

/* Macros to write bits and fields of bits */

#define SET_BIT(REG, BIT)     ((REG) |=  (1 << (BIT)))  
#define CLEAR_BIT(REG, BIT)   ((REG) &= ~(1 << (BIT))) 

#define WRITE_BIT(REG, BIT, VAL) \
    do { \
        if (VAL) SET_BIT(REG, BIT); \
        else      CLEAR_BIT(REG, BIT); \
    } while(0)

#define WRITE_FIELD(REG, MASK, SHIFT, VAL) \
    do { \
        (REG) = ((REG) & ~(MASK)) | (((VAL) << (SHIFT)) & (MASK)); \
    } while(0)

extern volatile struct cci_regs_t *p_cci_regs;

/* Enable/Disable and Reset all counters ( including counter cycles) */

void enable_allcounters();
void disable_allcounters();
void reset_allcounters();

/* CCI cycles */

void cycle_counter_enable();
void cycle_counter_disable();
void cycle_counter_reset();
uint32_t cycle_counter_get();

/* Configure event counters */

struct cci_counters_cfg{
    enum cci_events events;
    uint8_t interface;
    uint8_t counter;
};

void cci_pmu_start();
int cci_setup_counters(const struct cci_counters_cfg *cfg, size_t num_events);
uint32_t pmu_cci_counter_get(uint8_t counter);

static inline uint8_t cci_event_to_hwcode(enum cci_events ev)
{
    return cci_event_table[ev].event_code;
}

static inline const char *cci_getevent(enum cci_events ev)
{
    return cci_event_table[ev].name;
}

/* Print events */

void save_events();
void print_samples();

/* Validate config */

int cci_validate_config(const struct cci_counters_cfg *cfg, size_t num_events);

#endif