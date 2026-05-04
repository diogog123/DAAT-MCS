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

extern void initialise_benchmark(void);
extern void warm_caches(int heat);
extern int benchmark(void);
extern int verify_benchmark(int r);

void _fini(void) {
}

#define WARMUP_HEAT 10


enum {
    HC_PROFILE_CPU_READY = 3,
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

    
    int correct;
    volatile int result;
    
    if(!cpu_is_master()) {
        return;
    }
    
    
    initialise_benchmark ();
    warm_caches (WARMUP_HEAT);
    
    profiler_set_cpu_ready();


    while(1)
    {
        result = benchmark ();
        correct = verify_benchmark (result);
        profiler_set_checkpoint();
    }
}