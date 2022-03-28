ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_v1
FROM $BASE_CONTAINER


#
#ARG JUPYTERLAB_VERSION=2.1.5
#
#RUN apt-get update -y && \
#    # apt-get install -y python3-pip && \
#    pip3 install wget pyspark==${SPARK_VERSION} jupyterlab==${JUPYTERLAB_VERSION}
#
#ENV SHARED_WORKSPACE=/data
#EXPOSE 8888
#WORKDIR ${SHARED_WORKSPACE}
#CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=

USER root
COPY *.sh ./
RUN chmod +x *.sh

USER centos
# jupyter
COPY *.ipynb /home/centos/
COPY requirements.txt .
RUN pip install -r requirements.txt

CMD ["/bin/bash", "/home/centos/jupyter_statup.sh"]

# docker build -t spark32 .
# docker run -itd -p8888:8888 -p8080:8080 -p7077:7077 -p6066:6066 spark32