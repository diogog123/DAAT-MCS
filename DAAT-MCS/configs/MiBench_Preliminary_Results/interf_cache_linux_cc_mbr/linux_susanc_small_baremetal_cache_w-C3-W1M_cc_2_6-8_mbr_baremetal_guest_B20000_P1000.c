#include <config.h>

VM_IMAGE(linux_image, XSTR(BAO_WRKDIR_IMGS/MiBench_Preliminary_Results/linux_susanc_small.bin))
VM_IMAGE(baremetal_cache, XSTR(BAO_WRKDIR_IMGS/MiBench_Preliminary_Results/baremetal_cache_w-C3-W1M.bin))

struct config config = {

	CONFIG_HEADER

	.shmemlist_size = 1,
	.shmemlist = (struct shmem []){
		[0] = { .size = 0x00010000, }

	},

	.vmlist_size = 2,
	.vmlist = (struct vm_config[]) {

        {
            .image = {
                .base_addr = 0x40000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x40000000,
            .cpu_affinity = 0x0,
            .colors = 0x3,
            

            .platform = {
                .cpu_num = 1,

                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x40000000,
                        .size = 0x10000000,
                    },
                },

                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* UART1 */
                        .pa = 0xFF010000,
                        .va = 0xFF010000,
                        .size = 0x1000,
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {54}                         
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {27}                         
                    }
                },

                .arch = {
                    .gic = {
                        .gicc_addr = (paddr_t) 0xF9020000,
                        .gicd_addr = (paddr_t) 0xF9010000
                    },
                }
            },
        },

        { 
            .image = {
                .base_addr = 0x00000000,
                .load_addr = VM_IMAGE_OFFSET(baremetal_cache),
                .size = VM_IMAGE_SIZE(baremetal_cache)
            },

            .entry = 0x00000000,
            .cpu_affinity = 0xE,
            .colors = 0xfc,
            .mem_throth = {
				.budget = 20000,
				.period_us = 1000,
			},
	

            .platform = {
                .cpu_num = 3,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x00000000,
                        .size = 0x8000000
                    }
                },

                .dev_num = 2,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* UART 0 (mapped at aurt1) */
                        .pa = 0xFF010000,
                        .va = 0xFF000000,
                        .size = 0x1000,                                  
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts =  (irqid_t[]) {27}                         
                    },
                },

                .arch = {
                    .gic = {
                        .gicc_addr = (paddr_t) 0xF9020000,
                        .gicd_addr = (paddr_t) 0xF9010000
                    },
                }
            },
        },

	}
};
