ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER

ENV  SPARK_VERSION=3.2.1
ENV  HADOOP_VERSION=3.2
ENV  HADOOP_VERSION_FULL=3.2.0
ENV  HADOOP_VERSION_=3.2.0

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
ENV PATH $SPARK_HOME/bin/:/home/centos/.local/bin:$PATH
ENV PYTHONPATH $SPARK_HOME/python:/home/centos/.local/bin:$SPARK_HOME/python/lib/py4j-0.10.9.3-src.zip

ENV LIVY_VERSION=0.8.0-incubating
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV LIVY_LOG_DIR=/var/log/livy
ENV LIVY_LOG_FILE=/var/log/livy/livy--server.out
ENV LIVY_HOME /opt/livy

ARG MAVEN_VERSION=3.8.6
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries
ENV MAVEN_HOME /opt/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# OCI spark3.2.1 hadoop3.1
ENV HDFS_CONNECTOR_DL_URL=https://github.com/oracle/oci-hdfs-connector/releases/download/v3.3.1.0.3.4/oci-hdfs.zip
ENV JDBC_JAR_URL=https://repo.maven.apache.org/maven2/com/oracle/database/jdbc/ojdbc8/21.3.0.0/ojdbc8-21.3.0.0.jar
#ENV SPARK_URL=https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2-scala2.13.tgz
ENV SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala2.13.tgz"
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
RUN yum install -y sudo

RUN yum install epel-release -y
RUN yum install -y curl jq httpie unzip net-tools  git vim wget software-properties-common ssh net-tools ca-certificates

RUN yum install -y tesseract
RUN yum install -y poppler-utils
RUN yum install -y gcc
RUN yum install -y xz-devel
RUN yum install -y tesseract-langpack-ben tesseract-langpack-guj tesseract-langpack-hin tesseract-langpack-kan tesseract-langpack-mar tesseract-langpack-mal tesseract-langpack-tam tesseract-langpack-tel

# 1. JDK
RUN yum install -y  $JDK_NAME  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all

# 2. maven
RUN mkdir -p /opt/maven /opt/maven/ref
RUN echo ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1
RUN rm -f /tmp/apache-maven.tar.gz
RUN ln -s /opt/maven/bin/mvn /usr/bin/mvn

# 3. spark  + hadoop
RUN wget --no-verbose -O apache-spark.tgz  $SPARK_URL \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz

#aws hadoop/s3
# 4. OCI
RUN mkdir -p /tmp/oci/oci-hdfs && \
    cd  /tmp/oci && \
    wget $HDFS_CONNECTOR_DL_URL  -P /tmp/oci  && \
    unzip /tmp/oci/*.zip -d /tmp/oci/oci-hdfs   && \
    cp /tmp/oci/oci-hdfs/lib/*.jar  $SPARK_HOME/jars/ && \
    cp /tmp/oci/oci-hdfs/third-party/lib/*.jar $SPARK_HOME/jars

# 5. OCI JDBC
# resolve duplication
RUN wget $JDBC_JAR_URL  -P $SPARK_HOME/jars/

# 6. copy additional files
COPY 3rdparty/jars ${SPARK_HOME}/jars

#  docker logs
RUN mkdir -p $SPARK_LOG_DIR && touch $SPARK_MASTER_LOG && touch $SPARK_WORKER_LOG && ln -sf /dev/stdout $SPARK_MASTER_LOG && ln -sf /dev/stdout $SPARK_WORKER_LOG



#Install maven artifacts
#RUN mvn install:install-file   -DgroupId=io.delta   -DartifactId=delta-contribs_2.13   -Dversion=1.2.1   -Dfile=${SPARK_HOME}/jars/delta-contribs_2.13-1.2.1.jar   -DgeneratePom=true   -Dpackaging=jar
#RUN mvn install:install-file   -DgroupId=com.oracle.oci.sdk   -DartifactId=oci-hdfs-connector   -Dversion=3.3.1.0.3.4   -Dfile=${SPARK_HOME}/jars/oci-hdfs-connector-3.3.1.0.3.4.jar   -DgeneratePom=true   -Dpackaging=jar
#RUN mvn install:install-file   -DgroupId=org.glassfish.jersey.connectors   -DartifactId=jersey-apache-connector   -Dversion=3.1.0-M2   -Dfile=${SPARK_HOME}/jars/oci-hdfs-connector-3.3.1.0.3.4.jar   -DgeneratePom=true   -Dpackaging=jar
# mvn dependency:get -DremoteRepositories=https://www.sonatype.com/products/nexus-repository/  -Dartifact=com.oracle.oci.sdk:oci-hdfs-connector:3.3.1.0.3.4

# mvn
WORKDIR /build
RUN mkdir -p ~/.m2
COPY ./settings.xml ~/.m2/settings.xml
RUN mkdir -p /build/spark-streaming-pom
COPY ./spark-streaming-pom.xml /build/spark-streaming-pom/pom.xml
RUN cd /build/spark-streaming-pom \
    && ls -alt ~/.m2 \
    &&  mvn -DremoteRepositories=https://www.sonatype.com/products/nexus-repository/ dependency:copy-dependencies -DoutputDirectory=$SPARK_HOME/jars \
    && ls -alt ~/.m2

#mvn dependency:get -DremoteRepositories=https://www.sonatype.com/products/nexus-repository/ \
#     -Dartifact=com.oracle.oci.sdk:oci-hdfs-connector:3.3.1.0.3.4  -DoutputDirectory=$SPARK_HOME/jars
#################

##################################################################

# 8. PYTHON
ENV PYTHON_VERSION=3.8.12
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && set -ex \
    && yum update -y \
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
    && yum clean all \
    && tar -zxvf Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure prefix=/usr/local/python3 \
    && make \
    && make install \
    && make clean \
    && rm -rf /Python-${PYTHON_VERSION}* \
    && yum install -y epel-release \
    && yum install -y python-pip \
    && yum clean all
#  set to python3 by default
RUN set -ex \
    #  back up older versions of python
    && mv /usr/bin/python /usr/bin/python27 \
    && mv /usr/bin/pip /usr/bin/pip-python2.7 \
    #  configuration defaults to python3 \
    && rm /usr/bin/python3 \
    && ln /usr/local/python3/bin/python3.8 /usr/bin/python3 \
    && ln -s /usr/local/python3/bin/python3.8 /usr/bin/python \
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
#  fixed due to modification of python version yum failure problem todo: yum-config-manager
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/libexec/urlgrabber-ext-down \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum-config-manager
##################################################################


WORKDIR /opt

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

ENV PATH /home/centos/.local/bin:$PATH
ENV PYTHONPATH /home/centos/.local/bin:$PYTHONPATH

USER centos
RUN mkdir /home/centos/.jupyter
COPY jupyter_notebook_config.py /home/centos/.jupyter/.

# python
RUN python3 -V
RUN python -V
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN python3 -V

CMD ["/bin/bash", "/home/centos/statup_base.sh"]

