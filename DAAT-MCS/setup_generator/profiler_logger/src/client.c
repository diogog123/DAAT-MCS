#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <signal.h>
#include <sys/mman.h>
#include <arpa/inet.h>
#include <errno.h>

#include <profiling_tcp.h>

#define PAGE_SIZE 4096
#define DEV_MEM "/dev/mem"

#define RUN_PROFILLER_HYPERCALL_ID 0x2
#define SLEEP_TIME_US 10000

#define STORE_BUFFER_TAG_READY         0x00acce55
#define STORE_BUFFER_TAG_NOT_READY     0xdeadbeef
#define STORE_BUFFER_TAG_SIZE_BYTES    8

static int sock_fd;
static void* mapped_base = NULL;
static void* shared_data = NULL;
static int mem_fd = -1;

static size_t shmem_size = 0;
static size_t store_buffer_size = 0;
static uint64_t shmem_phys_addr = 0;
static uint64_t num_store_buffers = 0;
static size_t tx_packet_size = 0;

void cache_flush_range(void* addr, size_t size) {
    for(size_t i=0; i<size; i+=sizeof(int)) {
        asm volatile("DC CIVAC, %0" :: "r"(addr + i));
    }
}

// Simulated value; in practice this should be written by the IPI handler
volatile int current_index = 0;

// bool is_store_buffer_ready() {
//     // check if the first 16 bytes of the shared memory is 0xacce55
//     char* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
//     char read_msg[6];
//     memcpy(read_msg, buffer_ptr, 6);
    
//     if(strncmp(read_msg, "0xacce55", 6) == 0) {
//         return true;
//     }
//     return false;
// }

bool is_store_buffer_ready() {
    // check if the first 16 bytes of the shared memory is 0xacce55
    int* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
    bool ret = false;

    // force the reload of data from memory instead of use cached data
    // for the first 8 bytes
    // for(size_t i=0; i<STORE_BUFFER_TAG_SIZE_BYTES; i+=sizeof(int)) {
    //     asm volatile("DC CIVAC, %0" :: "r"(buffer_ptr + i));
    // }
    cache_flush_range(buffer_ptr, STORE_BUFFER_TAG_SIZE_BYTES);
    int store_buffer_status = *buffer_ptr;

    // int* buffer_ptr_cpy = buffer_ptr;
    // for(int i=0; i<32; i++) {
    //     printf("Buffer[%d]: %d\n", i, *buffer_ptr_cpy);
    //     buffer_ptr_cpy = (uint32_t*)buffer_ptr_cpy + 1;
    // }

    ret = (*buffer_ptr == STORE_BUFFER_TAG_READY) ? true : false;
    // printf("store buffer status: %d\n", store_buffer_status);
    return ret;
}

void set_store_buffer_ready() {
    int* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
    *buffer_ptr = STORE_BUFFER_TAG_NOT_READY;
}

// void set_store_buffer_ready() {
//     // write the first 16 bytes of the shared memory with 0xdeadbeef and padd with 0
//     char* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
//     // memcopy 0xdeadbeef to buffer_ptr
//     char* msg = "0xdeadbeef";
//     // reset buffer_ptr
//     memset(buffer_ptr, 0, store_buffer_size);
//     memcpy(buffer_ptr, msg, strlen(msg));
// }


void set_store_buffer_not_ready() {
    int* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
    *buffer_ptr = STORE_BUFFER_TAG_NOT_READY;
}

// === IPI Signal Handler ===
void logger_send_data() {

    // printf("Reading shared memory...\n");
    void* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
    // skip first 8 bytes
    buffer_ptr = (uint8_t*)buffer_ptr + STORE_BUFFER_TAG_SIZE_BYTES;
    cache_flush_range(buffer_ptr, store_buffer_size - STORE_BUFFER_TAG_SIZE_BYTES);

    // void* buffer_ptr_copy = buffer_ptr;
    // for(int i=0; i<32; i++) {
    //     printf("Buffer[%d]: %d\n", i, *(uint32_t*)buffer_ptr_copy);
    //     buffer_ptr_copy = (uint32_t*)buffer_ptr_copy + 1;
    // }

    // void* buffer_ptr = (uint8_t*)shared_data + (current_index * store_buffer_size);
    // ssize_t sent = send(sock_fd, buffer_ptr, store_buffer_size, 0);
    ssize_t sent = send(sock_fd, buffer_ptr, tx_packet_size, 0);
    if (sent < 0) {
        perror("send");
    } else {
        printf("Sent %ld bytes from store_buffer[%d]\n [address %lx]", sent, current_index, buffer_ptr);
    }

    // set_store_buffer_not_ready();    
    current_index++;
    if (current_index >= num_store_buffers) {
        current_index = 0; // Reset index if it exceeds the number of buffers
    }
}

// === Setup memory mapping ===
// bool map_shared_memory(uint64_t phys_addr, size_t size) {
//     mem_fd = open(DEV_MEM, O_RDONLY | O_SYNC);
//     if (mem_fd < 0) {
//         perror("open /dev/mem");
//         return false;
//     }

//     off_t page_offset = phys_addr % PAGE_SIZE;
//     off_t aligned_addr = phys_addr - page_offset;
//     size_t map_size = size + page_offset;

//     mapped_base = mmap(NULL, map_size, PROT_READ, MAP_SHARED, mem_fd, aligned_addr);
//     if (mapped_base == MAP_FAILED) {
//         perror("mmap");
//         close(mem_fd);
//         return false;
//     }

//     shared_data = (uint8_t*)mapped_base + page_offset;
//     return true;
// }

bool map_shared_memory(uint64_t phys_addr, size_t size) {
    mem_fd = open(DEV_MEM, O_RDWR | O_SYNC);
    if (mem_fd < 0) {
        perror("open /dev/mem");
        return false;
    }

    off_t page_offset = phys_addr % PAGE_SIZE;
    off_t aligned_addr = phys_addr - page_offset;
    size_t map_size = size + page_offset;

    mapped_base = mmap(NULL, map_size, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, aligned_addr);  // ✨ Add PROT_WRITE
    if (mapped_base == MAP_FAILED) {
        perror("mmap");
        close(mem_fd);
        return false;
    }

    shared_data = (uint8_t*)mapped_base + page_offset;
    return true;
}

void cleanup() {
    if (mapped_base) {
        munmap(mapped_base, shmem_size + (shmem_phys_addr % PAGE_SIZE));
    }
    if (mem_fd >= 0) {
        close(mem_fd);
    }
    close(sock_fd);
}

int send_hypercall(int hypercall_id, int arg1, int arg2, int arg3) {
    const char *hypercall_path = "/dev/baohypercall0";
    char buffer[64];

    // Format the string like: "3 4 5 6"
    snprintf(buffer, sizeof(buffer), "%d %d %d %d", hypercall_id, arg1, arg2, arg3);

    int fd = open(hypercall_path, O_WRONLY);
    if (fd < 0) {
        perror("Failed to open hypercall device");
        return -1;
    }

    ssize_t bytes_written = write(fd, buffer, strlen(buffer));
    if (bytes_written < 0) {
        perror("Failed to write hypercall");
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}

void profiler_logger() {
    while(!is_store_buffer_ready()) {
        //sleep(SLEEP_TIME_US);
        usleep(SLEEP_TIME_US);
    }

    logger_send_data();
    set_store_buffer_not_ready();
}

int main(int argc, char *argv[]) {
    if (argc != 7) {
        fprintf(stderr, "Usage: %s <server_ip> <shmem_phys_addr> <shmem_size> <store_buffer_size> <num_store_buffers> <tx_packet_size> \n", argv[0]);
        return 1;
    }

    char* server_ip = argv[1];
    shmem_phys_addr = strtoull(argv[2], NULL, 0);
    shmem_size = strtoul(argv[3], NULL, 0);
    store_buffer_size = strtoul(argv[4], NULL, 0);
    num_store_buffers = strtoull(argv[5], NULL, 0);
    tx_packet_size = strtoul(argv[6], NULL, 0);

    int total_shmem_size = store_buffer_size * num_store_buffers;

    // if (store_buffer_size == 0 || shmem_size == 0 || shmem_phys_addr == 0 || store_buffer_size > shmem_size) {
    //     fprintf(stderr, "Invalid arguments\n");
    //     return 1;
    // }

    
    struct sockaddr_in server_addr;
    if (!tcp_client_create_and_connect(&sock_fd, &server_addr, server_ip)) {
        cleanup();
        return 1;
    }

    printf("total memory to be allocated: %lu\n", total_shmem_size);
    if (!map_shared_memory(shmem_phys_addr, total_shmem_size)) {
        return 1;
    }
    printf("shared memory mapped successfully at %p\n", shared_data);

    if (!tcp_client_profile_handshake(sock_fd)) {
        printf("Handshake failed\n");
        cleanup();
        return 1;
    }

    printf("Handshake successful. Waiting for IPIs...\n");
    printf("********************************************************************\n");

    send_hypercall(RUN_PROFILLER_HYPERCALL_ID, 0, 0, 0);

    while (1) {
        profiler_logger();
    }

    cleanup();
    return 0;
}



