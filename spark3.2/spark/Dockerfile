FROM  duplocloud/anyservice:spark_3_2_base_centos_v5

WORKDIR /home/centos
USER root
COPY *.sh .
RUN chmod +x *.sh
USER centos
COPY requirements.txt .
RUN pip3 install -r requirements.txt



CMD ["/bin/bash", "/home/centos/statup_centos.sh"]
