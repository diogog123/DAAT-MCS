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

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <cpu.h>
#include <wfi.h>
#include <spinlock.h>
#include <plat.h>
#include <irq.h>
#include <uart.h>
#include <timer.h>

/* Platform-related configurations*/
#define CACHE_LINE_SIZE     64

/* Benchmark-related configurations */
#define NUM_CPUS            3
#define INTERF_BUF_SIZE     0x100000
#define ENABLE_READS        0
#define ENABLE_WRITES       1
#define IVAC_CACHE        0
#define CIVAC_CACHE        0

#define CPU_INTERF_BUF_SIZE (INTERF_BUF_SIZE/NUM_CPUS)
volatile uint64_t interf_buf[NUM_CPUS][CPU_INTERF_BUF_SIZE/sizeof(uint64_t)]  __attribute__((aligned(INTERF_BUF_SIZE)));

void evict_cache_line(uint64_t addr) {
    asm volatile("DC CIVAC, %0" :: "r"(addr));
}

void cache_clean_and_invalidate(uint64_t addr) {
    asm volatile("DC CIVAC, %0" :: "r"(addr));
}

void cache_invalidate(uint64_t addr) {
    asm volatile("DC IVAC, %0" :: "r"(addr));
}

void add_memory_sync_barrier(uint64_t addr) {
    asm volatile("" : : "r"(addr) : "memory");
}

spinlock_t cpu_ticket_lock = SPINLOCK_INITVAL;



#define CPU_INTERF_BUF_SIZE (INTERF_BUF_SIZE/NUM_CPUS)
volatile uint64_t cpu_interf_buf[NUM_CPUS][CPU_INTERF_BUF_SIZE/sizeof(uint64_t)]  __attribute__((aligned(INTERF_BUF_SIZE)));

enum {
    HC_PROFILE_CPU_READY = 9,
    HC_PROFILE_SET_CHECKPOINT = 4,
    HC_PROFILE_STOP = 6,
};

#define SMCC32_FID_VND_HYP_SRVC 0x86000000

static uint64_t send_hypercall(uint64_t hc_id, uint64_t arg1, uint64_t arg2, uint64_t arg3) {
    register uint64_t r0 asm("x0") = SMCC32_FID_VND_HYP_SRVC | hc_id;
    register uint64_t r1 asm("x1") = arg1;
    register uint64_t r2 asm("x2") = arg2;
    register uint64_t r3 asm("x3") = arg3;

    asm volatile("hvc   #0\n"
                : "=r"(r0)
                : "r"(r0), "r"(r1), "r"(r2), "r"(r3));
    return r0;
}

static uint64_t profiler_set_cpu_ready() {
    return send_hypercall(HC_PROFILE_CPU_READY, 0, 0, 0);
}

static uint64_t profiler_set_checkpoint() {
    return send_hypercall(HC_PROFILE_SET_CHECKPOINT, 0, 0, 0);
}

static uint64_t profiler_stop() {
    return send_hypercall(HC_PROFILE_STOP, 0, 0, 0);
}



void main(void){

    static volatile size_t buf_index_ticket = 0;
    size_t buf_index;

    spin_lock(&cpu_ticket_lock);
    buf_index = buf_index_ticket;
    buf_index_ticket += 1;
    spin_unlock(&cpu_ticket_lock);

    if(buf_index >= NUM_CPUS) return;

    const size_t bufid = buf_index;
    const size_t range = CPU_INTERF_BUF_SIZE/sizeof(uint64_t);
    const size_t stride = CACHE_LINE_SIZE/sizeof(uint64_t);
    const size_t base = 0;

    // profiler_set_cpu_ready();

    while(true) {

        #if(ENABLE_WRITES)
            for(size_t i = base; i < (base+range); i += stride) {
                cpu_interf_buf[bufid][i] = i;
            }
        #endif

        #if(ENABLE_READS)
            for(size_t i = base; i < (base+range); i += stride) {
                (void)cpu_interf_buf[bufid][i];
            }
        #endif

        #if(IVAC_CACHE)
            for(size_t i = base; i < (base+range); i += stride) {
                cache_invalidate((uint64_t)&cpu_interf_buf[bufid][i]);
            }
        #endif

        #if(CIVAC_CACHE)
            for(size_t i = base; i < (base+range); i += stride) {
                cache_clean_and_invalidate((uint64_t)&cpu_interf_buf[bufid][i]);
        }
        #endif

    }
}