#include <config.h>

VM_IMAGE(linux_image, XSTR(BAO_WRKDIR_IMGS/MiBench_Preliminary_Results/linux_susanc_small.bin))

struct config config = {

	CONFIG_HEADER

	.shmemlist_size = 1,
	.shmemlist = (struct shmem []){
		[0] = { .size = 0x00010000, }

	},

	.vmlist_size = 1,
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
	}
};
