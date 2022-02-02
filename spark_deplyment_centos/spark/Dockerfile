FROM  duplocloud/anyservice:spark_3_2_centos_base_v1

WORKDIR /home/centos
USER root
COPY *.sh .
RUN chmod +x *.sh
USER centos
COPY requirements.txt .
RUN pip install -r requirements.txt



CMD ["/bin/bash", "/home/centos/statup_centos.sh"]
