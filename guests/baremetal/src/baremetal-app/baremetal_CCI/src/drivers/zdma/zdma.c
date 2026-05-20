#include <zdma.h>

struct zdma_ch_hw {
    volatile uint32_t err_ctr;
    volatile uint8_t res0[0x100 - 0x04];
    volatile uint32_t isr;
    volatile uint32_t imr;
    volatile uint32_t ien;
    volatile uint32_t ids;
    volatile uint32_t ctrl0;
    volatile uint32_t ctrl1;
    volatile uint32_t fci;
    volatile uint32_t status;
    volatile uint32_t data_attr;
    volatile uint32_t dscr_attr;
    volatile uint32_t src_dscr_word0;
    volatile uint32_t src_dscr_word1;
    volatile uint32_t src_dscr_word2;
    volatile uint32_t src_dscr_word3;
    volatile uint32_t dst_dscr_word0;
    volatile uint32_t dst_dscr_word1;
    volatile uint32_t dst_dscr_word2;
    volatile uint32_t dst_dscr_word3;
    volatile uint32_t wr_only_word0;
    volatile uint32_t wr_only_word1;
    volatile uint32_t wr_only_word2;
    volatile uint32_t wr_only_word3;
    volatile uint32_t src_start_lsb;
    volatile uint32_t src_start_msb;
    volatile uint32_t dst_start_lsb;
    volatile uint32_t dst_start_msb;
    volatile uint8_t res1[0x188 - 0x168];
    volatile uint32_t total_byte;
    volatile uint32_t rate_ctrl;
    volatile uint32_t irq_src_acct;
    volatile uint32_t irq_dst_acct;
    volatile uint8_t res2[0x200 - 0x198];
    volatile uint32_t ctrl2;
} __attribute__((packed, aligned(0x10000)));

void zdma_ch_init(struct zdma_ch_hw* zdma_ch, enum zdma_mode mode) {
    if (mode == ZDMA_MODE_SCATTER_GATHER) {
        zdma_ch->ctrl0 |= (UINT32_C(1) << 6);
    } else {
        zdma_ch->ctrl0 &= ~(UINT32_C(1) << 6);
        zdma_ch->ctrl0 &= ~(UINT32_C(3) << 4);
        if (mode == ZDMA_MODE_SIMPLE_RO) {
            zdma_ch->ctrl0 |= (UINT32_C(2) << 4);
        } else if (mode == ZDMA_MODE_SIMPLE_WO) {
            zdma_ch->ctrl0 |= (UINT32_C(1) << 4);
        }
    }
    while ((zdma_ch->status != 0) && (zdma_ch->status != 3))  { }
}

void zdma_ch_set_src_addr(struct zdma_ch_hw* zdma_ch, uintptr_t addr) {
    zdma_ch->src_dscr_word0 = (uint32_t) addr;
    zdma_ch->src_dscr_word1 = (uint32_t)(addr >> 32);
    //zdma_ch->src_dscr_word3 |= 1; 
} 

void zdma_ch_set_dst_addr(struct zdma_ch_hw* zdma_ch, uintptr_t addr) {
    zdma_ch->dst_dscr_word0 = (uint32_t) addr;
    zdma_ch->dst_dscr_word1 = (uint32_t)(addr >> 32);
    //zdma_ch->dst_dscr_word3 |= 1;
} 

void zdma_ch_set_src_size(struct zdma_ch_hw* zdma_ch, size_t size) {
    zdma_ch->src_dscr_word2 = size;
}

void zdma_ch_set_dst_size(struct zdma_ch_hw* zdma_ch, size_t size) {
    zdma_ch->dst_dscr_word2 = size;
} 

void zdma_ch_set_coherent(struct zdma_ch_hw* zdma_ch) {
    zdma_ch->dst_dscr_word3 |= UINT32_C(1);
    zdma_ch->src_dscr_word3 |= UINT32_C(1);
    zdma_ch->data_attr |= (UINT32_C(0xF) << 22); // ARCACHE
    zdma_ch->data_attr |= (UINT32_C(0xF) << 8);  // AWCACHE
} 

void zdma_ch_set_noncoherent(struct zdma_ch_hw* zdma_ch) {
    zdma_ch->dst_dscr_word3 |= UINT32_C(0);
    zdma_ch->src_dscr_word3 |= UINT32_C(0);
} 

void zdma_ch_set_size(struct zdma_ch_hw* zdma_ch, size_t size) {
    zdma_ch_set_src_size(zdma_ch, size);
    zdma_ch_set_dst_size(zdma_ch, size);
}

void zdma_ch_start(struct zdma_ch_hw* zdma_ch) {
    zdma_ch->ctrl2 = 1;
}

void zdma_ch_poll_end(struct zdma_ch_hw* zdma_ch) {
    while(zdma_ch->ctrl2 != 0) { }
}

bool zdma_ch_check_finish(struct zdma_ch_hw* zdma_ch){

    return zdma_ch->ctrl2 == 0;

}