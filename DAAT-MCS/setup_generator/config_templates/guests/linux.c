VM_IMAGE(linux_image, XSTR(BAO_WRKDIR_IMGS/#linux_name#.bin))

        {
            .image = {
                .base_addr = 0x40000000,
                .load_addr = VM_IMAGE_OFFSET(linux_image),
                .size = VM_IMAGE_SIZE(linux_image)
            },

            .entry = 0x40000000,
            #linux_cpu_affinity_config#
            #linux_cache_coloring_config#
            #linux_mem_br_config#

            .platform = {
                #linux_cpu_num_config#

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