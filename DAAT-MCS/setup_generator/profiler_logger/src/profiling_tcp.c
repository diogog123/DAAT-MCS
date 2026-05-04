#include <profiling_tcp.h>
#include <errno.h>

#define MAX_RETRIES 3

char *client_commands[] = {
    "[TCP_CMD] profiler_ready [PC]",                                         // 1. #TCP_PC#_profiler_ready_#TCP_PC#
    "[TCP_CMD] profiler_start [PC]",                                         // 2. #TCP_PC#_profiler_start_#TCP_PC#
    "[TCP_CMD] profiler_stop [PC]",                                          // 3. #TCP_PC#_profiler_stop_#TCP_PC#
    "[TCP_CMD] profiler_ack [PC]"                                            // 4. #TCP_PC#_profiler_ack_#TCP_PC#
};

char* server_commands[] = {
    "[TCP_CMD] profiler_set_events [PS]",
    "[TCP_CMD] profiler_set_sampling_period [PS]",
    "[TCP_CMD] profiler_run [PS]"
};

void send_command(int sock_fd, const char *command) {
    send(sock_fd, command, strlen(command), 0);
}

void recv_command(int sock_fd, char *buffer, int timeout) {
    char temp_buffer[BUFFER_SIZE] = {0};

    if(timeout > 0) {
        struct timeval tv;
        tv.tv_sec = timeout;
        tv.tv_usec = 0;
        setsockopt(sock_fd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof(tv));
    }

    recv(sock_fd, temp_buffer, BUFFER_SIZE - 1, 0);
    char *start = strstr(temp_buffer, "[TCP_CMD]");
    if (!start) {
        buffer[0] = '\0';
        return;
    }

    char *end_pc = strstr(start, "[PC]");
    char *end_ps = strstr(start, "[PS]");

    char *end = NULL;
    if (end_pc && end_ps) {
        end = (end_pc < end_ps) ? end_pc : end_ps;
    } else if (end_pc) {
        end = end_pc;
    } else if (end_ps) {
        end = end_ps;
    }

    if (end) {
        size_t length = (end - start) + 4;
        strncpy(buffer, start, length);
        buffer[length] = '\0';
    } else {
        buffer[0] = '\0';
    }
}

/************************************************************************************************** */

// Timeout config (set once)
void set_socket_timeout(int sock_fd, int seconds) {
    struct timeval timeout;
    timeout.tv_sec = seconds;
    timeout.tv_usec = 0;
    if (setsockopt(sock_fd, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout)) < 0) {
        perror("setsockopt failed");
    }
}

// Retry wrapper around recv()
int recv_command_with_retries(int sock_fd, char *buffer, int max_retries) {
    for (int attempt = 1; attempt <= max_retries; ++attempt) {
        ssize_t received = recv(sock_fd, buffer, BUFFER_SIZE - 1, 0);
        if (received > 0) {
            buffer[received] = '\0';
            return 0;  // Success
        }

        if (errno == EAGAIN || errno == EWOULDBLOCK) {
            fprintf(stderr, "[Retry %d/%d] Timeout waiting for server...\n", attempt, max_retries);
        } else {
            perror("recv failed");
            return -1;
        }

        sleep(1); // Optional: wait a bit before retrying
    }

    fprintf(stderr, "Failed to receive data after %d retries\n", max_retries);
    return -1;
}

/************************************************************************************************** */

enum enum_client_commands parse_recv_client_command(char *buffer, int* args) {

    char *token = strtok(buffer, " ");
    token = strtok(NULL," ");
    int i = 0;
    bool valid_command = false;

    for(i=0; i<NUM_CLIENT_COMMANDS-1;i++) 
    {
        if(strstr(client_commands[i], token) != NULL) {
            valid_command = true;
            break;
        }
    }

    int arg_idx = 0;
    if(valid_command) {
        while(token != NULL) {
            token = strtok(NULL, " ");
            if(token != NULL) {
                args[arg_idx] = atoi(token);
                arg_idx++;
            }
        }
    }

    return i;    
}

enum enum_server_commands parse_recv_server_command(char *buffer, int* args) {

    char *token = strtok(buffer, " ");
    token = strtok(NULL, " ");
    int i = 0;
    bool valid_command = false;

    for(i=0; i<NUM_SERVER_COMMANDS-1;i++) 
    {
        if(strstr(server_commands[i], token) != NULL) {
            valid_command = true;
            break;
        }
    }

    int arg_idx = 0;
    if(valid_command) {
        while(token != NULL) {
            token = strtok(NULL, " ");
            if(token != NULL) {
                if(isdigit(token[0])) {
                    args[arg_idx] = atoi(token);
                    arg_idx++;
                }
            }
        }
    }
    return i;    
}

// ToDo: need to change this function to send the correct configuration
bool tcp_server_profile_handshake(int sock_fd) {
    /* procedure:
    1. the client must send a profiler_ready signal
    2. wait for server response
    3. the server must send a list of events
    4. the client must send a profiler_ack signal
    5. wait for server response
    6. the server must send a sampling period
    7. the client must send a profiler_ack signal
    8. wait for server response
    9. the server must send a start signal
    10. the client must send a profiler_ack signal
    */

    int retry = 100;
    char buffer[BUFFER_SIZE];
    int args[10];

    while(retry > 0) {
        recv_command(sock_fd, buffer, 1);

        if(parse_recv_client_command(buffer, args) == PROFILER_READY) {
            send_command(sock_fd, "[TCP_CMD] profiler_run [PS]");
            recv_command(sock_fd, buffer, 1);
            return true;
        }

        retry--;
    }
    // recv_command(sock_fd, buffer, 1);
    // printf("Received command 1: %s\n", buffer);
    // // if(parse_recv_client_command(buffer, args) == PROFILER_READY) {
    // //     send_command(sock_fd, "[TCP_CMD] profiler_set_events 6 12 32 21 31 44 58 [PS]");
    // //     printf("sent command 1\n");
    // //     recv_command(sock_fd, buffer, 0);
    // // }
    // // printf("Received command 2: %s\n", buffer);
    // // if(parse_recv_client_command(buffer, args) == PROFILER_ACK) {
    // //     send_command(sock_fd, "[TCP_CMD] profiler_set_sampling_period 1000 [PS]");
    // //     printf("sent command 2\n");
    // //     recv_command(sock_fd, buffer, 0);
    // // }
    // // printf("Received command 3: %s\n", buffer);
    // if(parse_recv_client_command(buffer, args) == PROFILER_READY) {
    //     send_command(sock_fd, "[TCP_CMD] profiler_run [PS]");
    //     printf("sent command 3\n");
    //     recv_command(sock_fd, buffer, 0);
    //     return true;
    // }

    return false;    
}

// ToDo: need to change this to fill the correct configuration structure
bool tcp_client_profile_handshake(int sock_fd) {
    /* procedure:
    1. the client must send a profiler_ready signal
    2. wait for server response
    3. the server must send a list of events
    4. the client must send a profiler_ack signal
    5. wait for server response
    6. the server must send a sampling period
    7. the client must send a profiler_ack signal
    8. wait for server response
    9. the server must send a start signal
    10. the client must send a profiler_ack signal
    */

    // send_command(sock_fd, "[TCP_CMD] profiler_ready [PC]");
    // char buffer[BUFFER_SIZE];
    // recv_command(sock_fd, buffer, 0);

    // int args[10];
    // if(parse_recv_server_command(buffer, args) == PROFILER_SET_EVENTS) {
    //     send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");
    //     // pmu_configure_counters(args);
    //     recv_command(sock_fd, buffer, 0);
    // }

    // if(parse_recv_server_command(buffer, args) == PROFILER_SET_SAMPLING_PERIOD) {
    //     send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");
    //     recv_command(sock_fd, buffer, 0);
    // }

    // if(parse_recv_server_command(buffer, args) == PROFILER_RUN) {
    //     send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");
    //     return true;
    // }
    
    // return false;

    char buffer[BUFFER_SIZE];
    int args[10];

    // Set timeout for all recv operations
    set_socket_timeout(sock_fd, 5);  // 5 seconds timeout

    // Step 1: Send "profiler_ready"
    send_command(sock_fd, "[TCP_CMD] profiler_ready [PC]");

    // Step 2: Wait for server response
    if (recv_command_with_retries(sock_fd, buffer, MAX_RETRIES) < 0) return false;
    printf("Received command: %s\n", buffer);

    // Step 3: Expect SET_EVENTS
    if (parse_recv_server_command(buffer, args) != PROFILER_SET_EVENTS) {
        fprintf(stderr, "Unexpected command. Expected PROFILER_SET_EVENTS.\n");
        return false;
    }

    // Step 4: Send ack
    send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");

    // Step 5: Wait for SET_SAMPLING_PERIOD
    if (recv_command_with_retries(sock_fd, buffer, MAX_RETRIES) < 0) return false;
    printf("Received command: %s\n", buffer);

    if (parse_recv_server_command(buffer, args) != PROFILER_SET_SAMPLING_PERIOD) {
        fprintf(stderr, "Unexpected command. Expected PROFILER_SET_SAMPLING_PERIOD.\n");
        return false;
    }

    // Step 6: Send ack
    send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");

    // Step 7: Wait for RUN
    if (recv_command_with_retries(sock_fd, buffer, MAX_RETRIES) < 0) return false;
    printf("Received command: %s\n", buffer);

    if (parse_recv_server_command(buffer, args) != PROFILER_RUN) {
        fprintf(stderr, "Unexpected command. Expected PROFILER_RUN.\n");
        return false;
    }

    // Step 8: Final ack
    send_command(sock_fd, "[TCP_CMD] profiler_ack [PC]");

    return true;
}


bool tcp_client_create_and_connect(int *sock_fd, struct sockaddr_in *server_addr, char* server_ip) {

    if ((*sock_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("Socket creation failed");
        return false;
    }

    server_addr->sin_family = AF_INET;
    server_addr->sin_port = htons(SERVER_PORT);
    if (inet_pton(AF_INET, server_ip, &(server_addr->sin_addr)) <= 0) {
        printf("Invalid address");
        close(*sock_fd);
        return false;
    }

    if (connect(*sock_fd, (struct sockaddr *)server_addr, sizeof(*server_addr)) < 0) {
        printf("Connection failed");
        close(*sock_fd);
        return false;
    }

    printf("Connected to server at %s:%d\n", server_ip, SERVER_PORT);
    return true;
}

bool tcp_server_create_and_connect(int *server_fd, int *client_fd, struct sockaddr_in *server_addr) {
    // Create socket

    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);

    if ((*server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("Socket creation failed");
        return false;
    }

    int opt = 1;
    if (setsockopt(*server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        perror("setsockopt(SO_REUSEADDR) failed");
        close(*server_fd);
        return false;
    }

    // Bind address
    server_addr->sin_family = AF_INET;
    server_addr->sin_addr.s_addr = INADDR_ANY;
    server_addr->sin_port = htons(PORT);

    if (bind(*server_fd, (struct sockaddr *)server_addr, sizeof(*server_addr)) < 0) {
        perror("Bind failed");
        close(*server_fd);
        return false;
    }

    // Listen for connections
    if (listen(*server_fd, 5) < 0) {
        perror("Listen failed");
        close(*server_fd);
        return false;
    }

    printf("TCP Server listening on port %d...\n", PORT);

    // Accept a client
    if ((*client_fd = accept(*server_fd, (struct sockaddr *)&client_addr, &client_len)) < 0) {
        perror("Accept failed");
        close(*server_fd);
        return false;
    }

    // printf("Client connected from %s:%d\n", inet_ntoa(server_addr->sin_addr), ntohs(server_addr->sin_port));
    return true;
}




