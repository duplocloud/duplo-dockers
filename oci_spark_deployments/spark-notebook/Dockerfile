ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_v1
FROM $BASE_CONTAINER

USER root
COPY *.sh ./
RUN chmod +x *.sh

USER centos
# jupyter
RUN mkdir -p /home/centos/notebook/mobility_eval
COPY *.ipynb /home/centos/notebook/
COPY mobility_eval/* /home/centos/notebook/mobility_eval/
COPY work/ /home/centos/notebooks/

COPY requirements.txt .
RUN pip install -r requirements.txt

CMD ["/bin/bash", "/home/centos/jupyter_statup.sh"]
