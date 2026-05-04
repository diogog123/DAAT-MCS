sleep 0.5
echo "[START] Profilling Started"
cd /root/benchmarks/MiBench/automotive/susan; seq 10 | xargs -Iz ./runme_small-c.sh; perf stat --table -n -r 1000 -e l2d_cache_refill ./runme_small-c.sh
echo "[END] Profiling Completed"
