

(avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) 

100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[30m])) * 100)