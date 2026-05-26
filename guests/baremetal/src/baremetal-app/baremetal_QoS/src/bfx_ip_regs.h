#ifndef DEVIL_IP_REGS_H
#define DEVIL_IP_REGS_H

// Control Reg bits
#define EN_pos      0
// #define RESERVED 1
#define FUNC_pos    5
    #define RESERVED1       0
    #define RESERVED2       1
    #define FUNC_ADL        2
    #define FUNC_ADT        3
    #define FUNC_RS        1
    #define FUNC_WS        2
    #define FUNC_RNS       3
    #define FUNC_WNS       4
#define CRRESP_pos  9
#define ACFLT_pos   14
#define ADDRFLT_pos 15
// #define RESERVED 16
// #define RESERVED 17
#define ADLEN_pos   18
#define ADTEN_pos   19
#define ONESHOT_pos 20
#define MONEN_pos   21
#define CMD_pos     22
    #define CMD_LEAK                    0
    #define CMD_POISON                  1
    #define CMD_TAMPER_CL               2
    #define CMD_DELAY_CR                3
    #define CMD_DEANON                  4
    #define CMD_HOLD                    5
    #define CMD_REDIRECT                6
    #define CMD_BFX_SIGNATURE           7
    #define CMD_BFX_MONITOR_VETTED_CODE 8
    #define CMD_BFX_BURN                9
#define STENDEN_pos   26
#define SNEAKEN_pos   27
#define REREADSEN_pos 28
#define BFX_EN_pos    29

// Control Reg mask
#define EN_mask       0xFFFFFFFE
#define FUNC_mask     0xFFFFFE1F

// Status Reg bits
#define OSH_END_pos         0
#define BUSY_pos            1
#define DEANON_COUNT_pos    2
#define BFX_READY_pos       18  
#define BFX_BURNED_pos      19

#define READ_ONCE           0b0000
#define WRITE_LINE_UNIQUE   0b001
#define WRITE_BACK          0b011

#define READONCE_EN            0b0000000001
#define READSHARED_EN          0b0000000010
#define READCLEAN_EN           0b0000000100
#define READNOTSHAREDDIRTY_EN  0b0000001000
#define READUNIQUE_EN          0b0000010000
#define CLEANUNIQUE_EN         0b0000100000
#define MAKEUNIQUE_EN          0b0001000000
#define CLEANSHARED_EN         0b0010000000
#define CLEANINVALID_EN        0b0100000000
#define MAKEINVALIDE_EN        0b1000000000
#define ALL_EN                 0b1111111111

#define READONCE            0b0000 
#define READSHARED          0b0001 
#define READCLEAN           0b0010
#define READNOTSHAREDDIRTY  0b0011         
#define READUNIQUE          0b0111 
#define CLEANUNIQUE         0b1011 
#define MAKEUNIQUE          0b1100 
#define CLEANSHARED         0b1000 
#define CLEANINVALID        0b1001     
#define MAKEINVALIDE        0b1101     

typedef struct bfx_ip_regs {
    uint32_t ctrl;
    uint32_t status;
    uint32_t p_delay;
    uint32_t acsnoop;
    uint32_t base_addr;
    uint32_t mem_size;
    uint32_t arsnoop;
    uint32_t l_araddr;
    uint32_t h_araddr;
    uint32_t awsnoop;
    uint32_t l_awaddr;
    uint32_t h_awaddr;
    uint32_t reserved[4];
    uint32_t DATA[16];       
    uint32_t PATTERN[16];       
    uint32_t PATTERN_SIZE; 
    uint32_t WORD_INDEX; 
    uint32_t END_PATTERN[16];       
    uint32_t END_PATTERN_SIZE; 
    uint32_t DEANON_ADDR_DATA; 
    uint32_t Sneak_target_snoop; 
    uint32_t Sneak_target_addr; 
    uint32_t Sneak_target_size; 
    uint32_t Sneak_addr; 
    uint32_t Sneak_snoop;
    uint32_t Bfx_Read_Offset;
} bfx_ip_regs_t;

#define BFX_SETUP               0
#define BFX_WAIT_SETUP          1
#define BFX_MONITOR_VETTED_CODE 2
#define BFX_BURN                3
#define BFX_DISABLE             4

#define PAGE_MASK               0xFFF

#endif