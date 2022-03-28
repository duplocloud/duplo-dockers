ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER

ARG JAVA_MAJOR_VERSION=11
ENV JDK_NAME=java-${JAVA_MAJOR_VERSION}-openjdk-devel

#
ENV  SPARK_MASTER_PORT=7077
ENV  SPARK_MASTER_WEBUI_PORT=8080
ENV  SPARK_WORKER_WEBUI_PORT=8080
ENV  SPARK_WORKER_PORT=7000
ENV  PYTHONHASHSEED=1

#
ENV SPARK_HOME=/opt/spark
ENV HADOOP_HOME /opt/hadoop
ENV LIVY_HOME /opt/livy
ENV  HADOOP_VERSION=3.2
ENV  HADOOP_VERSION_FULL=3.2.2
#
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV LIVY_LOG_DIR=/var/log/livy
ENV LIVY_LOG_FILE=/var/log/livy/livy--server.out

#
ENV SPARK_LOG_DIR=/home/centos/logs
ENV SPARK_MASTER_LOG=/home/centos/logs/spark-master.out
ENV SPARK_WORKER_LOG=/home/centos/logs/spark-worker.out

ENV PATH $SPARK_HOME/bin/:$LIVY_HOME/bin:$PATH


USER root

RUN yum clean all
RUN yum  update  -y

RUN yum install epel-release -y
RUN yum install -y sudo git curl yq jq httpie unzip net-tools  vim wget software-properties-common ssh net-tools ca-certificates python-pip
RUN python --version
RUN pip --version


# java
RUN yum install -y  $JDK_NAME  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all

# python (python 3.6 is deprecated ... should be py 3.8)
RUN ls -altR /usr/local/bin/
RUN ls -altR /test/static
COPY --from=builder /usr/local/lib/python3.8/site-packages/ /usr/local/lib/python3.8/site-packages/
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /test/static/* /test/static/
COPY --from=builder /build/deploy/opt /opt

RUN -sfn  /usr/local/lib/python3.8 /usr/bin/python3.8
RUN -sfn  /usr/local/lib/pip3.8 /usr/bin/pip3.8
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10
RUN alternatives --install /usr/bin/python python /usr/bin/python2 20


#  docker logs
RUN mkdir -p $SPARK_LOG_DIR && touch $SPARK_MASTER_LOG && touch $SPARK_WORKER_LOG && ln -sf /dev/stdout $SPARK_MASTER_LOG && ln -sf /dev/stdout $SPARK_WORKER_LOG


## Run under user "centos" and prepare for be running
RUN groupadd -r centos -g 1000 \
  && useradd -u 1000 -r -g centos -m -d /home/centos -s /sbin/nologin centos \
  && chmod 755 /home/centos

RUN mkdir -p /code
RUN mkdir -p /work

RUN chown -R centos /code \
  && usermod -g root -G `id -g centos` centos \
  && chmod -R "g+rwX" /code \
  && chown -R centos:root /code

RUN echo 'centos ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN chown -R centos /work \
  && chmod -R "g+rwX" /work \
  && chown -R centos:root /work

#mount code (cronjob), work (jupyter)
RUN mkdir -p /code
RUN mkdir -p /work

# code
COPY *.sh /home/centos/
COPY *.py /home/centos/
RUN chmod +x /home/centos/*.sh

RUN mkdir -p /opt/spark/work
RUN chown -R centos:centos  /opt/spark
RUN chown -R centos:centos  /home/centos

# non root user
WORKDIR /home/centos
USER centos
RUN mkdir /home/centos/.jupyter
COPY jupyter_notebook_config.py /home/centos/.jupyter/.
#COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# python
RUN python3 -V
RUN python -V
COPY requirements.txt .
RUN pip install -r requirements.txt


CMD ["/bin/bash", "/home/centos/statup_base.sh"]
