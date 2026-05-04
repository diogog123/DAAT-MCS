#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

#define DEFAULT_PORT 5201
#define BUFFER_SIZE 1024

#define NUM_PMU_COUNTERS 6
int pmu_counters[NUM_PMU_COUNTERS] = {0};

void collect_pmu_events(int* events, int num_counters) {
    for (int i = 0; i < num_counters; i++) {
        pmu_counters[i] = rand() % 1000;
    }
}

void send_text(int sock_fd, const char *message) {
    send(sock_fd, message, strlen(message), 0);
    printf("Sent: %s\n", message);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <server_ip> [port]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    char *server_ip = argv[1];
    int server_port = (argc >= 3) ? atoi(argv[2]) : DEFAULT_PORT;

    int sock_fd;
    struct sockaddr_in server_addr;
    char msg_buffer[100];
    int i = 0;

    // Create socket
    if ((sock_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("Socket creation failed");
        exit(EXIT_FAILURE);
    }

    // Set up server address struct
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(server_port);
    if (inet_pton(AF_INET, server_ip, &server_addr.sin_addr) <= 0) {
        perror("Invalid address");
        close(sock_fd);
        exit(EXIT_FAILURE);
    }

    // Connect to server
    if (connect(sock_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("Connection failed");
        close(sock_fd);
        exit(EXIT_FAILURE);
    }

    printf("Connected to server at %s:%d\n", server_ip, server_port);

    send_text(sock_fd, "Hello, Server!");

    while (1) {
        printf("Press ENTER to continue...\n");
        getchar();  // Wait for user input

        collect_pmu_events(pmu_counters, NUM_PMU_COUNTERS);

        sprintf(msg_buffer, "Sample %d: ", i);
        send_text(sock_fd, msg_buffer);

        sprintf(msg_buffer, "%d %d %d %d %d %d", 
            pmu_counters[0], pmu_counters[1], pmu_counters[2], 
            pmu_counters[3], pmu_counters[4], pmu_counters[5]);
        send_text(sock_fd, msg_buffer);
        
        i++;
        sleep(1);
    }

    close(sock_fd);
    return 0;
}
