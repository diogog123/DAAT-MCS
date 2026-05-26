
/** 
 * Bao, a Lightweight Static Partitioning Hypervisor 
 *
 * Copyright (c) Bao Project (www.bao-project.org), 2019-
 *
 * Authors:
 *      Jose Martins <jose.martins@bao-project.org>
 *      Sandro Pinto <sandro.pinto@bao-project.org>
 *
 * Bao is free software; you can redistribute it and/or modify it under the
 * terms of the GNU General Public License version 2 as published by the Free
 * Software Foundation, with a special exception exempting guest code from such
 * license. See the COPYING file in the top-level directory for details. 
 *
 */

#include <core.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h> 
#include <cpu.h>
#include <wfi.h>
#include <spinlock.h>
#include <plat.h>
#include <irq.h>
#include <uart.h>
#include <timer.h>
#include <zdma.h>
#include "bfx_ip_regs.h"
#include "pmu_cci400.h"

#define TIMER_INTERVAL        (TIME_S(1))
#define IP_BASE               0x80010000U
#define CACHE_LINE_SIZE       64
#define L1_BUFFER             (0x00004000) //16Kb
#define BUF_SIZE              L1_BUFFER

#define NUM_CPUS      3
#define MAX_DMA_CH    8
#define DMA_BASE_ADDRESS      0x00FFA80000
#define DMA_TRANSFER_SIZE     32 

//#define ADDRESSES_SPACE_BASE      0x00001000
//#define ADDRESSES_BUFFER_SIZE     0x1000     //4kb
//#define PAGE_MASK                 (ADDRESSES_BUFFER_SIZE - 1)  // 0xFFF
//#define BIT6_MASK                 (1 << 6)
//#define MAX_ADDR_INDEX            (1 << 11)   // 2048
#define WARMUP_STRIDE             64

#define NUM_RUNS         10
#define NUM_EVENTS       (sizeof(config)/sizeof(config[0]))

#define CNTV_CTL_ENABLE (1 << 0)
#define CNTV_CTL_IMASK  (1 << 1)

#define SNOOP_TYPE    2   // 1=Read Snoop, 2=Write Snoop
#define DMA_CHANNELS  8   // 1, 2, 4, 8
#define TEST_TYPE_SOLO        0
#define TEST_TYPE_DMA         1
#define TEST_TYPE_DMA_FPGA    2

#define TEST_TYPE     TEST_TYPE_DMA_FPGA  

#define COHERENCY     1

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

#define FPGA_DMA              0xB0000000UL

#define DMA_SIZE              32 
#define DDR_BASE              0x00084200

#define DMA_BASE_ADDRESS      0x00FFA80000
#define DMA_TRANSFER_SIZE     32 
struct cdma_regs_t {
 
    uint32_t CDMACR;                        /* 00h */
    uint32_t CDMASR;                        /* 04h */
    uint32_t CURDESC_PNTR;                  /* 08h */
    uint32_t CURDESC_PNTR_MSB;              /* 0Ch */
    uint32_t TAILDESC_PNTR;                 /* 10h */
    uint32_t TAILDESC_PNTR_MSB;             /* 14h */
    uint32_t SA;                            /* 18h */
    uint32_t SA_MSB;                        /* 1Ch */
    uint32_t DA;                            /* 20h */
    uint32_t DA_MSB;                        /* 24h */
    uint32_t BTT;                           /* 28h */
 
 };
 
 volatile struct cdma_regs_t *cdma = (volatile struct cdma_regs_t*) FPGA_DMA;
 
 /* CDMACR */
 
 #define KEY_HOLE_WRITE_BIT          5
 #define KEY_HOLE_READ_BIT           4
 #define SG_MODE                     3
 #define RESET                       2 
 
 /* CDMASR */
 
 #define DMADecErr                   6
 #define DMASlvErr                   5 
 #define DMAIntErr                   4
 #define IDLE                        1
 
 /* BTT */
 
 #define BTT_SHIFT                   0
 #define BTT_MASK                    (0x3FFFFFFU << BTT_SHIFT)

volatile uint32_t *ddr __attribute__((aligned(CACHE_LINE_SIZE))) = (volatile uint32_t *) DDR_BASE;
volatile uint32_t *dst = (volatile uint32_t *)0x00084400;

spinlock_t print_lock = SPINLOCK_INITVAL;

volatile uint64_t buffer[BUF_SIZE/sizeof(uint64_t)] __attribute__((aligned(L1_BUFFER)));

const size_t range = BUF_SIZE/sizeof(uint64_t);
const size_t stride = CACHE_LINE_SIZE/sizeof(uint64_t);
const size_t base = 0;

volatile bfx_ip_regs_t *bfx = (volatile bfx_ip_regs_t *)IP_BASE;

struct zdma_ch_hw* dma_channels[] = {
    (void*)(DMA_BASE_ADDRESS + 0 * 0x10000),    // Channel 0
    (void*)(DMA_BASE_ADDRESS + 1 * 0x10000),    // Channel 1  
    (void*)(DMA_BASE_ADDRESS + 2 * 0x10000),    // Channel 2    
    (void*)(DMA_BASE_ADDRESS + 3 * 0x10000),    // Channel 3
    (void*)(DMA_BASE_ADDRESS + 4 * 0x10000),    // Channel 4
    (void*)(DMA_BASE_ADDRESS + 5 * 0x10000),    // Channel 5
    (void*)(DMA_BASE_ADDRESS + 6 * 0x10000),    // Channel 6
    (void*)(DMA_BASE_ADDRESS + 7 * 0x10000),    // Channel 7
};

char uart_getchar_clean(void){

    char c;
        do {
            c = uart_getchar();
        } while (c == '\n' || c == '\r');  
    return c;
    
}

static inline void timer_int_en(bool en)
{
    if (en) {
        sysreg_cntv_ctl_el0_write(sysreg_cntv_ctl_el0_read() & ~CNTV_CTL_IMASK);
    } else {
        sysreg_cntv_ctl_el0_write(sysreg_cntv_ctl_el0_read() | CNTV_CTL_IMASK);
    }
}

static inline void timer_enable(void)
{
    timer_int_en(true);
    sysreg_cntv_ctl_el0_write(CNTV_CTL_ENABLE);
}

static inline void config_ip(bfx_ip_regs_t *bfx, uint8_t en, uint8_t func) {
    bfx->ctrl = (bfx->ctrl & ~(EN_mask | FUNC_mask))
              | (en << EN_pos)
              | (func << FUNC_pos);
}

void invalidateCache(void *address) {
    asm volatile (
        "dc ivac, %[addr]\n"  // Invalidate the data cache at address
        "dsb sy\n"            // Data Synchronization Barrier
        :                    // Output operands (none)
        : [addr] "r" (address)  // Input operands
        : "memory"            // Clobbered registers
    );
}

void invaliInstCache(void *address) {
    asm volatile (
        "ic ivau, %[addr]\n"  // Invalidate the instruction cache at address
        "dsb ish\n"            // Data Synchronization Barrier
        "isb sy\n"            // Instruction Synchronization Barrier
        :                    // Output operands (none)
        : [addr] "r" (address)  // Input operands
        : "memory"            // Clobbered registers
    );
}

void invalidate_all_instruction_cache() {
    asm volatile (
        "ic iallu\n"
        "dsb sy\n"
        "isb\n"
    );
}

// CL 0
unsigned int *ptr   = (unsigned int*)(0x40000000);
unsigned int *ptr1  = (unsigned int*)(0x40000004);
unsigned int *ptr2  = (unsigned int*)(0x40000008);
unsigned int *ptr3  = (unsigned int*)(0x4000000C);
unsigned int *ptr4  = (unsigned int*)(0x40000010);
unsigned int *ptr5  = (unsigned int*)(0x40000014);
unsigned int *ptr6  = (unsigned int*)(0x40000018);
unsigned int *ptr7  = (unsigned int*)(0x4000001C);
unsigned int *ptr8  = (unsigned int*)(0x40000020);
unsigned int *ptr9  = (unsigned int*)(0x40000024);
unsigned int *ptr10 = (unsigned int*)(0x40000028);
unsigned int *ptr11 = (unsigned int*)(0x4000002C);
unsigned int *ptr12 = (unsigned int*)(0x40000030);
unsigned int *ptr13 = (unsigned int*)(0x40000034);
unsigned int *ptr14 = (unsigned int*)(0x40000038);
unsigned int *ptr15 = (unsigned int*)(0x4000003C);
// CL 1
unsigned int *ptr_1_0  = (unsigned int*)(0x40000000+0x40);
unsigned int *ptr_1_1  = (unsigned int*)(0x40000004+0x40);
unsigned int *ptr_1_2  = (unsigned int*)(0x40000008+0x40);
unsigned int *ptr_1_3  = (unsigned int*)(0x4000000C+0x40);
unsigned int *ptr_1_4  = (unsigned int*)(0x40000010+0x40);
unsigned int *ptr_1_5  = (unsigned int*)(0x40000014+0x40);
unsigned int *ptr_1_6  = (unsigned int*)(0x40000018+0x40);
unsigned int *ptr_1_7  = (unsigned int*)(0x4000001C+0x40);
unsigned int *ptr_1_8  = (unsigned int*)(0x40000020+0x40);
unsigned int *ptr_1_9  = (unsigned int*)(0x40000024+0x40);
unsigned int *ptr_1_10 = (unsigned int*)(0x40000028+0x40);
unsigned int *ptr_1_11 = (unsigned int*)(0x4000002C+0x40);
unsigned int *ptr_1_12 = (unsigned int*)(0x40000030+0x40);
unsigned int *ptr_1_13 = (unsigned int*)(0x40000034+0x40);
unsigned int *ptr_1_14 = (unsigned int*)(0x40000038+0x40);
unsigned int *ptr_1_15 = (unsigned int*)(0x4000003C+0x40);

unsigned int *ptr8b  = (unsigned int*)(0x40000100);
unsigned int *ptr9b  = (unsigned int*)(0x40000104);
unsigned int *ptr10b = (unsigned int*)(0x40000108);
unsigned int *ptr11b = (unsigned int*)(0x4000010C);
unsigned int *ptr12b = (unsigned int*)(0x40000110);
unsigned int *ptr13b = (unsigned int*)(0x40000114);
unsigned int *ptr14b = (unsigned int*)(0x40000118);
unsigned int *ptr15b = (unsigned int*)(0x4000011C);

int DMA_channels = 0;
volatile size_t sample_count = 0;
size_t i = 0;

static const struct cci_counters_cfg config [] = {  /* Choose here your event , interface  and counter (check cci400_events.h) */ 
    {si_r_data_last_hs_snoop, 0 ,0},
    {si_r_data_last_hs_snoop, 2, 1},
    {si_rrq_hs_inner_or_outershareable, 0, 2},
    {si_rrq_hs_inner_or_outershareable, 2, 3},
  
}; /* YOU CAN ONLY MEASURE 4 EVENTS AT TIME BECAUSE WE ONLY HAD 4 COUNTERS */

unsigned long cci_events_samples[NUM_EVENTS][NUM_RUNS];

void save_events(){

    for(i = 0; i < NUM_EVENTS ; i++){
        uint8_t counter = config[i].counter;
        cci_events_samples[i][sample_count] = pmu_cci_counter_get(counter);
    }
}

typedef struct {
    uint64_t source;
    uint64_t destination;
} dma_transaction_t;

#define NUM_TXN 8

static const dma_transaction_t dma_pairs[NUM_TXN] = {
    {0x0000000000080040ULL, 0x0000000000080140ULL},
    {0x0000000000080050ULL, 0x0000000000080150ULL},
    {0x0000000000080060ULL, 0x0000000000080160ULL},
    {0x0000000000080070ULL, 0x0000000000080170ULL},
    {0x00000000000800C0ULL, 0x00000000000801C0ULL},
    {0x00000000000800D0ULL, 0x00000000000801D0ULL},
    {0x00000000000800E0ULL, 0x00000000000801E0ULL},
    {0x00000000000800F0ULL, 0x00000000000801F0ULL},
};

static inline void warmup_dma_pairs(const dma_transaction_t *pairs, int num_pairs)
{
    for (int i = 0; i < num_pairs; i++) {
        volatile uint64_t *src = (volatile uint64_t *)pairs[i].source;
        volatile uint64_t *dst = (volatile uint64_t *)pairs[i].destination;

        *src = 0xDEADBEEF;
        *dst = 0xDEADBEEF;
    }
}

void dma_interf_init(void){

    printf("Initializing %d DMA channel(s)...\n", DMA_channels);

        for(int ch = 0; ch < DMA_channels; ch++){
            zdma_ch_init(dma_channels[ch],ZDMA_MODE_SIMPLE);
            zdma_ch_set_size(dma_channels[ch], DMA_TRANSFER_SIZE);
        }
    
    printf("DMA Initialized!\n");

} 

volatile int core_state[NUM_CPUS] = {0, 0, 0, 0};   // 0=wfi, 1=running

uint32_t cpu_dma_chnls_assigned[NUM_CPUS] = {0};
uint32_t cpu_dma_chnls[NUM_CPUS][MAX_DMA_CH];

void assign_zdma_channels(int start_core) {
    int num_cores = NUM_CPUS - start_core;

    for (int i = 0; i < NUM_CPUS; i++) {
        cpu_dma_chnls_assigned[i] = 0;
    }

    for (int i = 0; i < DMA_channels; i++) {
        int cpu = start_core + (i % num_cores);
        cpu_dma_chnls[cpu][cpu_dma_chnls_assigned[cpu]] = i;
        cpu_dma_chnls_assigned[cpu]++;
    }
}

void run_core(uint32_t core_id) {
    for (int i = 0; i < cpu_dma_chnls_assigned[core_id]; i++) {
        int ch = cpu_dma_chnls[core_id][i];
        if (zdma_ch_check_finish(dma_channels[ch])) {
            zdma_ch_start(dma_channels[ch]);
        }
    }
}

void dma_interf_en(void) {
    unsigned long my_core = get_cpuid();

    if (cpu_dma_chnls_assigned[my_core] > 0) {
        core_state[my_core] = 1;
        run_core(my_core);
    } else {
        core_state[my_core] = 0;
        wfi();
    }
}

void fpga_dma_init(void){

    cdma->CDMACR |= (1U << RESET);
    while(cdma->CDMACR & (1U << RESET));
    printf("CDMA Reset done!\n");
    while(!(cdma->CDMASR & (1U << IDLE)));
    cdma->SA = 0x00084200; 
    cdma->DA = 0x00084400; 

}

void fpga_dma_en(void){
    
    core_state[0] = 1;
    while(!(cdma->CDMASR & (1U << IDLE)));
    WRITE_FIELD(cdma->BTT, BTT_MASK, BTT_SHIFT, DMA_SIZE);
}

void flush_single_address(void *addr) {
    asm volatile("dc civac, %0" :: "r"((uintptr_t)addr) : "memory");
    asm volatile("dsb sy" ::: "memory");
}

void timer_handler(unsigned id){

    printf("si_r_data_last_hs_snoop_handler_s0: %u\n",pmu_cci_counter_get(0));
    printf("si_r_data_last_hs_snoop_handler_s2: %u\n",pmu_cci_counter_get(1));
    printf("si_rrq_hs_inner_or_outershareable_handler_s0: %u\n",pmu_cci_counter_get(2));
    printf("si_rrq_hs_inner_or_outershareable_handler_s2: %u\n",pmu_cci_counter_get(3));
    printf("Core states: 0=%s 1=%s 2=%s 3=%s\n",
        core_state[0] ? "RUN" : "WFI",
        core_state[1] ? "RUN" : "WFI",
        core_state[2] ? "RUN" : "WFI",
        core_state[3] ? "RUN" : "WFI");
    timer_set(TIME_S(1));
}

void main(void){

    static volatile bool master_done = false;

    if(cpu_is_master()){
        printf("\nCCI Interference tests!\n");
        // irq_set_handler(TIMER_IRQ_ID, timer_handler);
        // timer_set(TIME_S(1));
        // irq_enable(TIMER_IRQ_ID);
        // irq_set_prio(TIMER_IRQ_ID, 0);
        const dma_transaction_t *txn;
        #if SNOOP_TYPE == 1
            printf("Read Snoop!\n");
            config_ip(bfx, 1, FUNC_RS);
        #elif SNOOP_TYPE == 2
            printf("Write Snoop!\n");
            config_ip(bfx, 1, FUNC_WS);
        #endif

        for (int i=0; i<16; i++) *(ptr + i) = i;

        // printf("[CCI] Configuring CCI PMU counters...\n");
        // if(cci_setup_counters(config, 4) == -1) return;

        // printf("[CCI] Starting CCI PMU...\n");
        // cci_pmu_start();
        // printf("[CCI] PMU started.\n");

        #if TEST_TYPE == TEST_TYPE_SOLO
            printf("TEST_TYPE_SOLO\n");
        #elif TEST_TYPE == TEST_TYPE_DMA         // dma
            DMA_channels = DMA_CHANNELS;
            printf("TEST_TYPE_DMA\n");
            printf("%d DMA Channel(s) Interference\n", DMA_channels);
            assign_zdma_channels(0); // ATENÇAO A ISTO QUANDO VOLTAR A FAZER OS MICROBENCHMARKS
            dma_interf_init();

            for (int ch = 0; ch < DMA_channels; ch++) {
                txn = &dma_pairs[ch % NUM_TXN];
                zdma_ch_set_src_addr(dma_channels[ch], txn->source);         
                zdma_ch_set_dst_addr(dma_channels[ch], txn->destination); 
            }
    
            warmup_dma_pairs(dma_pairs, DMA_channels);
        #elif TEST_TYPE == TEST_TYPE_DMA_FPGA  // dma+fpga
            DMA_channels = DMA_CHANNELS;
            printf("TEST_TYPE_DMA_FPGA\n");
            printf("%d DMA Channel(s) Interference\n", DMA_channels);
            assign_zdma_channels(1);  // ATENÇAO A ISTO QUANDO VOLTAR A FAZER OS MICROBENCHMARKS
            dma_interf_init();

            for (int ch = 0; ch < DMA_channels; ch++) {
                txn = &dma_pairs[ch % NUM_TXN];
                zdma_ch_set_src_addr(dma_channels[ch], txn->source);         
                zdma_ch_set_dst_addr(dma_channels[ch], txn->destination); 
            }
    
            printf("Writting to 0x00084200...\n");
            ddr[0] = 0xDEADBEEF;
            flush_single_address((void *)0x00084200);
            printf("SRC = 0x%08X\n", ddr[0]);

            warmup_dma_pairs(dma_pairs,DMA_channels);
            fpga_dma_init();

        #endif

        #if COHERENCY == 0
            printf("NON_COHERENT\n");
            #if TEST_TYPE == TEST_TYPE_DMA || TEST_TYPE == TEST_TYPE_DMA_FPGA
                for(int ch = 0; ch < DMA_channels; ch++){
                    zdma_ch_set_noncoherent(dma_channels[ch]);
                }
            #endif
        #elif COHERENCY == 1
            printf("COHERENT\n");
            #if TEST_TYPE == TEST_TYPE_DMA || TEST_TYPE == TEST_TYPE_DMA_FPGA
                for(int ch = 0; ch < DMA_channels; ch++){
                    zdma_ch_set_coherent(dma_channels[ch]);
                }
            #endif
        #endif
        
        //timer_enable();
        asm volatile("dsb sy" ::: "memory");
        master_done = true;
    }

    while(!master_done);

    while(1){
        
        #if TEST_TYPE == TEST_TYPE_SOLO        // solo
            for(size_t i = base; i < (base+range); i+= stride){
                buffer[i] = i;
            }
        #elif TEST_TYPE == TEST_TYPE_DMA       // dma
            dma_interf_en(); 
        #elif TEST_TYPE == TEST_TYPE_DMA_FPGA  // dma+fpga
            if(get_cpuid() == 0){
                fpga_dma_en();
            } else {
                dma_interf_en();
            }
        #endif

    }
}





