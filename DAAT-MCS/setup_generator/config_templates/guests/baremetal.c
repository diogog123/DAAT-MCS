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
