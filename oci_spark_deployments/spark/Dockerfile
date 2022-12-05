ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_base_v1
FROM $BASE_CONTAINER

WORKDIR /home/centos
USER root
COPY *.sh .
RUN chmod +x *.sh


CMD ["/bin/bash", "/home/centos/statup_centos.sh"]
