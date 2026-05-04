#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdint.h>
#include <errno.h>
#include <signal.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <profiling_tcp.h>

#define TIMEOUT_SECONDS 300
#define BUFFER_SIZE (32 * 1024 * 1024)

int server_fd = -1;
int client_fd = -1;

static int message_size = 0;
char output_file_name[512];

void cleanup_and_exit(int signum) {
    if (client_fd >= 0) {
        shutdown(client_fd, SHUT_RDWR);
        close(client_fd);
        client_fd = -1;
    }
    if (server_fd >= 0) {
        shutdown(server_fd, SHUT_RDWR);
        close(server_fd);
        server_fd = -1;
    }
    exit(0);
}

int main(int argc, char* argv[]) {
    struct sockaddr_in server_addr;
    char* buffer = NULL;
    size_t num_cpus = 0;

    if (argc < 5) {
        fprintf(stderr, "Usage: %s <message_size> <output_file> <num_events> <num_cpus>\n", argv[0]);
        return 1;
    }

    message_size = atoi(argv[1]);
    if (message_size <= 0 || message_size > BUFFER_SIZE) {
        fprintf(stderr, "Invalid message size: %d\n", message_size);
        return 1;
    }

    strncpy(output_file_name, argv[2], sizeof(output_file_name) - 1);
    output_file_name[sizeof(output_file_name) - 1] = '\0';

    // num_events argument still required for compat, but will be ignored here
    // (Alternatively you can remove it from command line and code if unused)
    // size_t num_events = (size_t)atoi(argv[3]);
    num_cpus = (size_t)atoi(argv[4]);

    if (num_cpus == 0) {
        fprintf(stderr, "num_cpus must be > 0\n");
        return 1;
    }

    printf("Message size: %d\n", message_size);
    printf("Output file: %s\n", output_file_name);
    printf("num_cpus: %zu\n", num_cpus);

    if (message_size % num_cpus != 0) {
        fprintf(stderr, "Warning: message size is not divisible by num_cpus. Results may be truncated.\n");
    }

    buffer = malloc(message_size);
    if (!buffer) {
        fprintf(stderr, "Failed to allocate buffer of size %d\n", message_size);
        cleanup_and_exit(1);
    }

    signal(SIGINT, cleanup_and_exit);
    signal(SIGTERM, cleanup_and_exit);

    tcp_server_create_and_connect(&server_fd, &client_fd, &server_addr);

    if (!tcp_server_profile_handshake(client_fd)) {
        fprintf(stderr, "Handshake failed\n");
        cleanup_and_exit(1);
    }

    struct timeval timeout = {
        .tv_sec = TIMEOUT_SECONDS,
        .tv_usec = 0
    };
    if (setsockopt(client_fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
        perror("setsockopt");
        cleanup_and_exit(1);
    }

    FILE* outfile = fopen(output_file_name, "w");
    if (!outfile) {
        perror("fopen");
        cleanup_and_exit(1);
    }

    size_t total_received = 0;
    while (total_received < (size_t)message_size) {
        ssize_t received = recv(client_fd, buffer + total_received, message_size - total_received, 0);

        if (received < 0) {
            if (errno == EWOULDBLOCK || errno == EAGAIN) {
                printf("recv timeout: waiting for data...\n");
                continue;
            } else {
                perror("recv failed");
                cleanup_and_exit(1);
            }
        } else if (received == 0) {
            if (total_received < (size_t)message_size) {
                fprintf(stderr, "Client disconnected prematurely\n");
                cleanup_and_exit(1);
            }
            break;
        } else {
            total_received += (size_t)received;
        }
    }
    printf("Total received bytes: %zu\n", total_received);

    if (total_received != (size_t)message_size) {
        fprintf(stderr, "Received bytes %zu do not match expected %d\n", total_received, message_size);
        cleanup_and_exit(1);
    }

    uint32_t* data = (uint32_t*)buffer;
    size_t chunk_size = message_size / (num_cpus * sizeof(uint32_t));
    chunk_size = chunk_size / sizeof(uint32_t);
    chunk_size = chunk_size * sizeof(uint32_t); // align to uint32_t
    size_t checkpoints_per_cpu = chunk_size;
    printf("Checkpoints per CPU: %zu\n", checkpoints_per_cpu);
    printf("Chunk size per CPU (in bytes): %zu\n", chunk_size);
    printf("Size of uint32_t: %zu\n", sizeof(uint32_t));
    printf("Num CPUs: %zu\n", num_cpus);
    printf("Total message size (in bytes): %d\n", message_size);

    fprintf(outfile, "======================================================\n");
    fprintf(outfile, "Aggregated checkpoints per CPU\n");

    
    for (size_t cpu = 0; cpu < num_cpus; ++cpu) {
        fprintf(outfile, "CPU%zu checkpoints:\n", cpu);
        size_t offset = cpu * checkpoints_per_cpu;

        for (size_t i = 0; i < checkpoints_per_cpu; ++i) {
            fprintf(outfile, "%u", data[offset + i]);
            if (i < checkpoints_per_cpu - 1)
                fprintf(outfile, " ");
        }
        fprintf(outfile, "\n");
    }

    fprintf(outfile, "\n");
    fflush(outfile);

    fclose(outfile);
    free(buffer);
    cleanup_and_exit(0);
    return 0;
}
