#include <config.h>

VM_IMAGE(linux_image, XSTR(BAO_WRKDIR_IMGS/CCI_macrobenchmarks/linux_cci_macrobenchmark.bin))
VM_IMAGE(baremetal_cci_TEST_TYPE_DMA_FPGA_snoop1_ch1_coh0_C4, XSTR(BAO_WRKDIR_IMGS/CCI_macrobenchmarks/baremetal_cci_TEST_TYPE_DMA_FPGA_snoop1_ch1_coh0_C4.bin))

struct config config = {

	CONFIG_HEADER

	.shmemlist_size = 1,
	.shmemlist = (struct shmem []){
		[0] = { .size = 0x00010000, }

	},

	.vmlist_size = 2,
	.vmlist = {

        {
            .image = {
                .base_addr = 0x40000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x40000000,
            .cpu_affinity = 0x0,
            
            

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
                .load_addr = VM_IMAGE_OFFSET(baremetal_cci_TEST_TYPE_DMA_FPGA_snoop1_ch1_coh0_C4),
                .size = VM_IMAGE_SIZE(baremetal_cci_TEST_TYPE_DMA_FPGA_snoop1_ch1_coh0_C4)
            },

            .entry = 0x00000000,
            .cpu_affinity = 0xF,
            
            

            .platform = {
                .cpu_num = 4,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x00000000, // Virtual Addr
                        .size = 0x70000000,
                        .place_phys=true,
                        .phys = 0x00000000 // Physical Addr
                    }
                },

                .dev_num = 14,
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
                    {   /* PL */
                        .pa = 0x80000000,
                        .va = 0x80000000,
                        .size = 0x30000
                    },
                    {
                        /* PL Porta HPM1 */
                        .pa = 0xB0000000,
                        .va = 0xB0000000,        
                        .size = 0xFFFF, 
                    },
                    {
                        /* PL Porta HPC0 */
                        .id = 0x200,
                        .pa = 0x00000000,
                        .va = 0x00000000,        
                        .size = 0x7FFFFFFF,
                    },
                    {   
                        /* CCI */
                        .pa = 0xFD6E0000,
                        .va = 0xFD6E0000,
                        .size = 0x10000,
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {186}                         
                    },
                    {
                        /* DMA CH0 */ 
                        .id = 0x868,
                        .pa = 0xFFA80000,
                        .va = 0xFFA80000,
                        .size = 0x10000
                    },
                    {
                        /* DMA CH1 */ 
                        .id = 0x869,
                        .pa = 0xFFA90000,
                        .va = 0xFFA90000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH2 */ 
                        .id = 0x86A,
                        .pa = 0xFFAA0000,
                        .va = 0xFFAA0000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH3 */ 
                        .id = 0x86B,
                        .pa = 0xFFAB0000,
                        .va = 0xFFAB0000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH4 */ 
                        .id = 0x86C,
                        .pa = 0xFFAC0000,
                        .va = 0xFFAC0000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH5 */ 
                        .id = 0x86D,
                        .pa = 0xFFAD0000,
                        .va = 0xFFAD0000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH6 */ 
                        .id = 0x86E,
                        .pa = 0xFFAE0000,
                        .va = 0xFFAE0000,
                        .size = 0x10000

                    },
                    {
                        /* DMA CH7 */ 
                        .id = 0x86F,
                        .pa = 0xFFAF0000,
                        .va = 0xFFAF0000,
                        .size = 0x10000

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
