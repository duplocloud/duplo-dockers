ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_v1
FROM $BASE_CONTAINER

USER root
COPY *.sh ./
RUN chmod +x *.sh

USER centos
# jupyter
COPY *.ipynb /home/centos/
COPY mobility_eval/ /home/centos/mobility_eval/
COPY work/ /home/centos/notebooks

# sam as base
#COPY requirements.txt .
#RUN pip install -r requirements.txt
#RUN python3 -m pip install dask distributed --upgrade

CMD ["/bin/bash", "/home/centos/jupyter_statup.sh"]
