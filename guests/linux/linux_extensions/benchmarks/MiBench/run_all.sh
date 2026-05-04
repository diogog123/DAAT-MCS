#!/bin/sh

MIBENCH_DIR=$(pwd)

WARM_UP=10
REPETITIONS=30
SLEEP_BETWEEN_RUNS=0.1

cd $MIBENCH_DIR/automotive/qsort
echo "-> mibench/automotive/qsort-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
echo "Repeating benchmark $REPETITIONS times for qsort-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small.sh
done

echo "-> mibench/automotive/qsort-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
echo "Repeating benchmark $REPETITIONS times for qsort-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large.sh
done

cd $MIBENCH_DIR/automotive/susan
echo "-> mibench/automotive/susanc-small"
seq $WARM_UP | xargs -Iz ./runme_small-c.sh
echo "Repeating benchmark $REPETITIONS times for susanc-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small-c.sh
done

echo "-> mibench/automotive/susanc-large"
seq $WARM_UP | xargs -Iz ./runme_large-c.sh
echo "Repeating benchmark $REPETITIONS times for susanc-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large-c.sh
done

echo "-> mibench/automotive/susane-small"
seq $WARM_UP | xargs -Iz ./runme_small-e.sh
echo "Repeating benchmark $REPETITIONS times for susane-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small-e.sh
done

echo "-> mibench/automotive/susane-large"
seq $WARM_UP | xargs -Iz ./runme_large-e.sh
echo "Repeating benchmark $REPETITIONS times for susane-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large-e.sh
done

echo "-> mibench/automotive/susans-small"
seq $WARM_UP | xargs -Iz ./runme_small-s.sh
echo "Repeating benchmark $REPETITIONS times for susans-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small-s.sh
done

echo "-> mibench/automotive/susans-large"
seq $WARM_UP | xargs -Iz ./runme_large-s.sh
echo "Repeating benchmark $REPETITIONS times for susans-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large-s.sh
done

cd $MIBENCH_DIR/automotive/bitcount
echo "-> mibench/automotive/bitcount-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
echo "Repeating benchmark $REPETITIONS times for bitcount-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small.sh
done

echo "-> mibench/automotive/bitcount-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
echo "Repeating benchmark $REPETITIONS times for bitcount-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large.sh
done

cd $MIBENCH_DIR/automotive/basicmath
echo "-> mibench/automotive/basicmath-small"
seq $WARM_UP | xargs -Iz ./runme_small.sh
echo "Repeating benchmark $REPETITIONS times for basicmath-small"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_small.sh
done

echo "-> mibench/automotive/basicmath-large"
seq $WARM_UP | xargs -Iz ./runme_large.sh
echo "Repeating benchmark $REPETITIONS times for basicmath-large"
for i in $(seq 1 $REPETITIONS); do
    echo "Run $i"
    sleep $SLEEP_BETWEEN_RUNS
    ./runme_large.sh
done
