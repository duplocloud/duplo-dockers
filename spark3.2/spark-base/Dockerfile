FROM centos:centos7

#spark
#ENV  SPARK_VERSION=3.1.1 #3.2.0
#ENV  HADOOP_VERSION=2.7 #3.2
ENV  SPARK_VERSION=3.2.0
ENV  HADOOP_VERSION=2.7
# for s3
ENV  HADOOP_VERSION_FULL=2.7.4
ENV  AWS_SDK_VERSION=1.11.199
#
ENV  SPARK_MASTER_PORT=7077
ENV  SPARK_MASTER_WEBUI_PORT=8080
ENV  SPARK_WORKER_WEBUI_PORT=8080
ENV  SPARK_WORKER_PORT=7000
ENV  PYTHONHASHSEED=1

# JAVA_APP_DIR is used by run-java.sh for finding the binaries
ENV JAVA_APP_DIR=/code \
    JAVA_MAJOR_VERSION=11
ENV JAVA_HOME /etc/alternatives/jre
##
ENV SPARK_HOME=/opt/spark
ENV SPARK_LOG_DIR=/home/centos/logs
ENV SPARK_MASTER_LOG=/home/centos/logs/spark-master.out
ENV SPARK_WORKER_LOG=/home/centos/logs/spark-worker.out
ENV PATH $SPARK_HOME/bin/:$PATH
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.2-src.zip

USER root
RUN yum install -y sudo

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

#python
RUN yum clean all
RUN yum update -y

# java
RUN yum install -y  java-11-openjdk-devel  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all

# scala

# Python
RUN yum install -y curl vim wget software-properties-common ssh net-tools ca-certificates python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1
RUN python -m pip install pip --upgrade

# spark
RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz

#aws hadoop/s3
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION_FULL}/hadoop-aws-${HADOOP_VERSION_FULL}.jar -P /opt/spark/jars/ && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -P /opt/spark/jars/

#copy additional files
COPY ./elasticsearch-hadoop-7.16.2/dist/elasticsearch-spark-20_2.11-7.16.2.jar ${SPARK_HOME}/jars/

#  docker logs
RUN mkdir -p $SPARK_LOG_DIR && touch $SPARK_MASTER_LOG && touch $SPARK_WORKER_LOG && ln -sf /dev/stdout $SPARK_MASTER_LOG && ln -sf /dev/stdout $SPARK_WORKER_LOG

# home centos
WORKDIR /home/centos
# code
COPY *.sh .
RUN chmod +x *.sh

RUN mkdir -p /opt/spark/work
RUN chown -R centos:centos  /opt/spark
RUN chown -R centos:centos  /home/centos

# non root user
USER centos
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# python
RUN python3 -V
RUN python -V
COPY requirements.txt .
RUN python -m pip install -r requirements.txt
RUN mkdir /home/centos/.jupyter
COPY jupyter_notebook_config.py /home/centos/.jupyter/.

CMD ["/bin/bash", "/home/centos/statup_base.sh"]
