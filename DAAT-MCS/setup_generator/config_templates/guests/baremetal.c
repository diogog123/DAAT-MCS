VM_IMAGE(#baremetal_image_name#, XSTR(BAO_WRKDIR_IMGS/#baremetal_name#.bin))

        { 
            .image = {
                .base_addr = 0x00000000,
                .load_addr = VM_IMAGE_OFFSET(#baremetal_image_name#),
                .size = VM_IMAGE_SIZE(#baremetal_image_name#)
            },

            .entry = 0x00000000,
            #baremetal_cpu_affinity_config#
            #baremetal_cache_coloring_config#
            #baremetal_mem_br_config#

            .platform = {
                #baremetal_cpu_num_config#
                
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
