
#include <core.h>

struct zdma_ch_hw;

enum zdma_mode {
    ZDMA_MODE_SIMPLE,
    ZDMA_MODE_SIMPLE_RO,
    ZDMA_MODE_SIMPLE_WO,
    ZDMA_MODE_SCATTER_GATHER,
};

void zdma_ch_init(struct zdma_ch_hw* zdma_ch, enum zdma_mode mode);
void zdma_ch_set_src_addr(struct zdma_ch_hw* zdma_ch, uintptr_t addr);
void zdma_ch_set_dst_addr(struct zdma_ch_hw* zdma_ch, uintptr_t addr);
void zdma_ch_set_src_size(struct zdma_ch_hw* zdma_ch, size_t size);
void zdma_ch_set_dst_size(struct zdma_ch_hw* zdma_ch, size_t size);
void zdma_ch_set_size(struct zdma_ch_hw* zdma_ch, size_t addr);
void zdma_ch_start(struct zdma_ch_hw* zdma_ch);
void zdma_ch_poll_end(struct zdma_ch_hw* zdma_ch);
void zdma_ch_set_coherent(struct zdma_ch_hw* zdma_ch);
void zdma_ch_set_noncoherent(struct zdma_ch_hw* zdma_ch);
bool zdma_ch_check_finish(struct zdma_ch_hw* zdma_ch);