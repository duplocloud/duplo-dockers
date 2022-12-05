FROM prom/prometheus:latest
RUN cp /etc/prometheus/prometheus.yml  /prometheus/prometheus-origin.yml
COPY prometheus.yml /etc/prometheus/prometheus.yml


#COPY startup.sh /startup.sh
#RUN chmod +x /startup.sh
# /bin/prometheus --config.file=/etc/prometheus/prometheus.yml
# --storage.tsdb.path=/prometheus
# --web.console.libraries=/usr/share/prometheus/console_libraries

# CMD ["/startup.sh"]
