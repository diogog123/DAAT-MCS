#include <config.h>

VM_IMAGE(Qos_test, "/media/diogo/rootfs/CCI_Interference/DAAT-MCS/guests/baremetal/src/baremetal-app/baremetal_QoS/build/zcu104/baremetal.bin");

struct config config = { 
     
    CONFIG_HEADER

    .vmlist_size = 1,
    .vmlist = {
        { 

	    .entry = 0x00000000,
	    
            .image = {
                .base_addr = 0x00000000,
                .load_addr = VM_IMAGE_OFFSET(Qos_test),
                .size = VM_IMAGE_SIZE(Qos_test)
            },

            .cpu_affinity=0b0001,

            .platform = {
                .cpu_num = 1,
                
                .region_num = 1,
                .regions =  (struct vm_mem_region[]) {
                    {
                        .base = 0x00000000, // Virtual Addr
                        .size = 0x70000000,
                        .place_phys=true,
                        .phys = 0x70000000 // Physical Addr
                    }
                },
                .dev_num = 6,
                .devs =  (struct vm_dev_region[]) {
                    {   
                        /* UART0 */
                        .pa = 0xFF000000,
                        .va = 0xFF000000,
                        .size = 0x1000,
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {53}                         
                    },
                    {   
                        /* Arch timer interrupt */
                        .interrupt_num = 1,
                        .interrupts = 
                            (irqid_t[]) {27}                         
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
                        /* GEM3 */
                        .id = 0x877, 
                        .pa = 0xff0e0000,
                        .va = 0xff0e0000,
                        .size = 0x1000,
                        .interrupt_num = 2,
                        .interrupts = 
                            (irqid_t[]) {95, 96}                           
                    },
                    {
                        /* PL Porta HPM0 */
                        .pa = 0xA0000000,
                        .va = 0xA0000000,        
                        .size = 0xFFFF, 
                    },
                    {
                        /* PL Porta HPC0 */
                        .id = 0x200,
                        .pa = 0x00000000,
                        .va = 0x00000000,        
                        .size = 0x7FFFFFFF,
                    },
                },

                .arch = {
                    .gic = {
                        .gicc_addr = 0xF9020000,
                        .gicd_addr = 0xF9010000
                    },
                }
            },
        },
    }
};