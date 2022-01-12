FROM  exoplatform/ubuntu:20.04

#ENV  SPARK_VERSION=3.1.1 #3.2.0
#ENV  HADOOP_VERSION=2.7 #3.2
#spark
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


#ENV SPARK_MASTER="spark://127.0.0.1:7077"
#ENV SPARK_WORKLOAD="master"

## ubuntu user
RUN groupadd --gid 1000 ubuntu \
    && useradd --uid 1000 --gid ubuntu --shell /bin/bash --create-home ubuntu


ENV SPARK_HOME=/opt/spark
ENV SPARK_LOG_DIR=/home/ubuntu/logs
ENV SPARK_MASTER_LOG=/home/ubuntu/logs/spark-master.out
ENV SPARK_WORKER_LOG=/home/ubuntu/logs/spark-worker.out
ENV PATH $SPARK_HOME/bin/:$PATH
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.2-src.zip


#jdk
RUN apt-get update && apt-get -y install openjdk-11-jdk-headless && rm -rf /var/lib/apt
#RUN apt-get update && apt-get -y install curl mlocate default-jdk -y

# PySpark
RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# spark
RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz

#aws hadoop
#s3
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION_FULL}/hadoop-aws-${HADOOP_VERSION_FULL}.jar -P /opt/spark/jars/ && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -P /opt/spark/jars/

#copy additional files
COPY ./elasticsearch-hadoop-7.16.2/dist/elasticsearch-spark-20_2.11-7.16.2.jar ${SPARK_HOME}/jars/

#  docker logs
RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_MASTER_LOG && \
touch $SPARK_WORKER_LOG && \
ln -sf /dev/stdout $SPARK_MASTER_LOG && \
ln -sf /dev/stdout $SPARK_WORKER_LOG

# jupyter
RUN pip install jupyter

EXPOSE 8080 7077 6066 8888


RUN mkdir /opt/spark/work

WORKDIR /home/ubuntu

# app
#WORKDIR /opt/spark

# code
COPY *.sh .
RUN chmod +x *.sh
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
RUN mkdir work

RUN chown -R ubuntu:ubuntu  /home/ubuntu

USER ubuntu
RUN mkdir /home/ubuntu/.jupyter
COPY jupyter_notebook_config.py /home/ubuntu/.jupyter/.

CMD ["/bin/bash", "/home/ubuntu/statup.sh"]

# docker build -t spark32 .
# docker run -itd -p8888:8888 -p8080:8080 -p7077:7077 -p6066:6066 spark32