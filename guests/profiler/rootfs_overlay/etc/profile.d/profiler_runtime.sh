#!/bin/bash

export SERVER_IP=192.168.1.216
export SHMEM_PHYS_ADDR=4026531840
export SHMEM_SIZE=65536
export STORE_BUFFER_SIZE=16384
export NUM_STORE_BUFFERS=2
export TX_PACKET_SIZE=16384

INTERFACE="eth0"
echo "Waiting for $INTERFACE to be up..."
while ! ip link show "$INTERFACE" | grep -qw "UP"; do
    sleep 1
done
echo "$INTERFACE is up, waiting for IP address..."
while ! ip addr show "$INTERFACE" | grep -q "inet "; do
    sleep 1
done
echo "IP obtained. Waiting for default route..."
while ! ip route show default | grep -q "dev $INTERFACE"; do
    sleep 1
done
echo "$INTERFACE is fully configured."

echo 'Launching profiler client application...'
echo "2 0 0 0" > /dev/baohypercall0
/root/client ${SERVER_IP} 5201 $SHMEM_PHYS_ADDR $STORE_BUFFER_SIZE
echo 'Profiler client application exited'
echo '--------------------------------------------------------'

while true; do
    sleep 1
done
exit 0
