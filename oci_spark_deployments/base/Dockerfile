ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER



#spark
#ENV  SPARK_VERSION=2.2.0
#ENV  SPARK_VERSION=3.2.1

#ENV  SPARK_VERSION=3.1.1
#ENV  HADOOP_VERSION=3.2
#ENV  HADOOP_VERSION_FULL=3.2.2

ENV  SPARK_VERSION=3.2.1
ENV  HADOOP_VERSION=3.2
ENV  HADOOP_VERSION_FULL=3.2.2

ENV  AWS_SDK_VERSION=1.11.199
#
ENV  SPARK_MASTER_PORT=7077
ENV  SPARK_MASTER_WEBUI_PORT=8080
ENV  SPARK_WORKER_WEBUI_PORT=8080
ENV  SPARK_WORKER_PORT=7000
ENV  PYTHONHASHSEED=1

# JAVA_APP_DIR is used by run-java.sh for finding the binaries
ENV JAVA_APP_DIR=/code
ENV JAVA_MAJOR_VERSION=11
#ENV JDK_NAME=java-11-openjdk-devel
ENV JAVA_MAJOR_VERSION=8
ENV JDK_NAME=java-1.8.0-openjdk-devel

#ENV skip_if_unavailable=1
ENV JAVA_HOME /etc/alternatives/jre
##
ENV SPARK_HOME=/opt/spark
ENV SPARK_LOG_DIR=/home/centos/logs
ENV SPARK_MASTER_LOG=/home/centos/logs/spark-master.out
ENV SPARK_WORKER_LOG=/home/centos/logs/spark-worker.out
ENV PATH $SPARK_HOME/bin/:$PATH
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.2-src.zip

ENV LIVY_VERSION=0.8.0-incubating
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV LIVY_LOG_DIR=/var/log/livy
ENV LIVY_LOG_FILE=/var/log/livy/livy--server.out
ENV LIVY_HOME /opt/livy
#ENV PATH $LIVY_HOME/bin:$PATH
ENV HADOOP_VERSION_=3.2.2
ENV HADOOP_HOME /opt/hadoop

ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ENV MAVEN_HOME /opt/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# OCI spark3.2.1 hadoop3.1
#https://github.com/oracle/oci-hdfs-connector/releases/download/v3.3.1.0.3.2/oci-hdfs.zip
ENV HDFS_CONNECTOR_DL_URL=https://github.com/oracle/oci-hdfs-connector/releases/download/v3.2.1.3/oci-hdfs.zip
ENV JDBC_JAR_URL=https://repo.maven.apache.org/maven2/com/oracle/database/jdbc/ojdbc8/21.3.0.0/ojdbc8-21.3.0.0.jar
ENV HADOOP_AWS_URL=https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION_FULL}/hadoop-aws-${HADOOP_VERSION_FULL}.jar
ENV AWS_JAVA_SDK_BUNDLE_URL=https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar
ENV SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"
#ENV HADOOP_URL=http://apache.mirrors.tds.net/hadoop/common/hadoop-${HADOOP_VERSION_}/hadoop-${HADOOP_VERSION_}.tar.gz
ENV HADOOP_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION_}/hadoop-${HADOOP_VERSION_}.tar.gz
USER root

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
RUN yum  update  -y
RUN yum install -y sudo  python-pip

RUN yum  install epel-release -y
RUN yum install -y curl jq httpie unzip net-tools  vim wget software-properties-common ssh net-tools ca-certificates

# java
RUN yum install -y  $JDK_NAME  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all

# spark
RUN wget --no-verbose -O apache-spark.tgz  $SPARK_URL \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz

#aws hadoop/s3
RUN wget $HADOOP_AWS_URL -P $SPARK_HOME/jars/
RUN wget $AWS_JAVA_SDK_BUNDLE_URL -P $SPARK_HOME/jars/
#OCI
RUN mkdir -p /tmp/oci/oci-hdfs && \
    cd  /tmp/oci && \
    wget $HDFS_CONNECTOR_DL_URL  -P /tmp/oci  && \
    unzip /tmp/oci/*.zip -d /tmp/oci/oci-hdfs   && \
    cp /tmp/oci/oci-hdfs/lib/*.jar /opt/spark/jars/ && \
    cp /tmp/oci/oci-hdfs/third-party/lib/*.jar $SPARK_HOME/jars

#RUN mv $SPARK_HOME/jars/jsr305-3.0.0.jar $SPARK_HOME/jars/jsr305-3.0.0.jar.original

#OCI JDBC
# resolve duplication
#RUN mv $SPARK_HOME/jars/jsr305-3.0.0.jar $SPARK_HOME/jars/jsr305-3.0.0.jar.original
RUN wget $JDBC_JAR_URL  -P $SPARK_HOME/jars/

#copy additional files
COPY 3rdparty/jars ${SPARK_HOME}/jars

#  docker logs
RUN mkdir -p $SPARK_LOG_DIR && touch $SPARK_MASTER_LOG && touch $SPARK_WORKER_LOG && ln -sf /dev/stdout $SPARK_MASTER_LOG && ln -sf /dev/stdout $SPARK_WORKER_LOG

#maven
RUN yum install -y git curl

RUN mkdir -p /opt/maven /opt/maven/ref
RUN echo ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1
RUN rm -f /tmp/apache-maven.tar.gz
RUN ln -s /opt/maven/bin/mvn /usr/bin/mvn



WORKDIR /build
RUN mkdir -p /build/spark-streaming-pom
COPY spark-streaming-pom.xml /build/spark-streaming-pom/pom.xml
RUN cd /build/spark-streaming-pom && \
        mvn dependency:copy-dependencies -DoutputDirectory=$SPARK_HOME/jars

RUN yum install -y   python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy
#RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1
RUN alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN alternatives --install /usr/bin/python python /usr/bin/python2 20
RUN alternatives --display python
RUN alternatives --auto python
RUN python3 -m pip install -U pip
RUN python3 -m pip install -U setuptools


# home centos
#WORKDIR /home/centos
#
#add livy into base
#COPY apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip /home/centos
##RUN unzip /home/centos/apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip
##COPY conf-livy /home/centos/apache-livy-0.8.0-incubating-SNAPSHOT-bin/conf
##RUN mv /home/centos/apache-livy-0.8.0-incubating-SNAPSHOT-bin /opt/livy
#COPY ./livy /opt/livy
#RUN chmod +x   /opt/livy/bin/livy-server
#RUN mkdir -p $LIVY_LOG_DIR && touch $LIVY_LOG_FILE   && ln -sf /dev/stdout $LIVY_LOG_FILE
#RUN chown centos -R $LIVY_LOG_DIR
#RUN chown centos -R $LIVY_LOG_FILE

WORKDIR /opt
##### is livy requires haddop lib?
#http://apache.mirrors.tds.net/hadoop/common/hadoop-${HADOOP_VERSION_}/hadoop-${HADOOP_VERSION_}.tar.gz
#https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION_}/hadoop-${HADOOP_VERSION_}.tar.gz
#https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
#http://apache.mirrors.tds.net/hadoop/common/hadoop-3.2.2/hadoop-${HADOOP_VERSION_}.tar.gz
RUN wget ${HADOOP_URL} &&  \
    tar -xzf hadoop-${HADOOP_VERSION_}.tar.gz && \
    mv hadoop-${HADOOP_VERSION_} $HADOOP_HOME

# code
COPY create_oci_profile.sh /
RUN chmod +x /create_oci_profile.sh

COPY *.sh /home/centos/
COPY *.py /home/centos/
RUN chmod +x /home/centos/*.sh

RUN mkdir -p /opt/spark/work
RUN chown -R centos:centos  /opt/spark
RUN chown -R centos:centos  /home/centos

# non root user
WORKDIR /home/centos

#COPY ./oci  /home/centos/.oci/
##RUN mv /home/centos/oci/ /home/centos/.oci/
#RUN ls  /home/centos/.oci/

COPY ./oci  /root/.oci/
COPY ./oci  /home/centos/.oci/
RUN ls  /home/centos/.oci/
#RUN mv /home/centos/oci /root/.oci/

USER centos
RUN mkdir /home/centos/.jupyter
COPY jupyter_notebook_config.py /home/centos/.jupyter/.

# python
RUN python3 -V
RUN python -V
COPY requirements.txt .
RUN pip install -r requirements.txt

#ENTRYPOINT ["/bin/bash", "/create_oci_profile.sh"]

CMD ["/bin/bash", "/home/centos/statup_base.sh"]
