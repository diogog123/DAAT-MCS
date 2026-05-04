#ifndef PROFILING_TCP_H
#define PROFILING_TCP_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <stdbool.h>
#include <ctype.h>

#define PORT 5201
#define SERVER_PORT 5201
#define BUFFER_SIZE 1024

#define NUM_CLIENT_COMMANDS 4
#define NUM_SERVER_COMMANDS 3

extern char *client_commands[];
extern char *server_commands[];

enum enum_client_commands {
    PROFILER_READY,
    PROFILER_START,
    PROFILER_STOP,
    PROFILER_ACK
};

enum enum_server_commands {
    PROFILER_SET_EVENTS,                                                        // 1. #TCP_PS#_profiler_set_events_#TCP_PS#
    PROFILER_SET_SAMPLING_PERIOD,                                               // 2. #TCP_PS#_profiler_set_sampling_period_#TCP_PS#
    PROFILER_RUN                                                                // 3. #TCP_PS#_profiler_run_#TCP_PS#
};

void send_command(int sock_fd, const char *command);
void recv_command(int sock_fd, char *buffer, int timeout);
enum enum_server_commands parse_recv_server_command(char *buffer, int* args);
enum enum_client_commands parse_recv_client_command(char *buffer, int* args);
bool tcp_client_create_and_connect(int *sock_fd, struct sockaddr_in *server_addr, char* server_ip);
bool tcp_server_create_and_connect(int *server_fd, int *client_fd, struct sockaddr_in *server_addr);
bool tcp_server_profile_handshake(int sock_fd);
bool tcp_client_profile_handshake(int sock_fd);

#endif
