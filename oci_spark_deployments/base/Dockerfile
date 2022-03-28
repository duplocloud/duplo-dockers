########################################### builder CONTAINER  ###########################################
########################################### builder CONTAINER  ###########################################
########################################### builder CONTAINER  ###########################################

ARG BASE_CONTAINER=centos:centos7
FROM $BASE_CONTAINER AS builder


#
ARG MAVEN_VERSION=3.6.3
ENV USER_HOME_DIR="/root"
ENV BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ENV MAVEN_HOME /opt/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
RUN export MAVEN_OPTS="-Xmx15g -XX:ReservedCodeCacheSize=x5g"

#
ARG JAVA_MAJOR_VERSION=11
#ARG JAVA_MAJOR_VERSION=1.8.0
ENV JDK_NAME=java-${JAVA_MAJOR_VERSION}-openjdk-devel
#ENV JDK_NAME=java-1.8.0-openjdk-devel

ENV DEPLOY_FOLDER=/build/deploy
ENV SPARK_JARS=$DEPLOY_FOLDER/3rdparty-jars
ENV OCI_JARS=$DEPLOY_FOLDER/oci-jars
ENV STREAMING_JARS=$DEPLOY_FOLDER/streaming-jars
RUN mkdir -p /test/static  /usr/share/info/ $DEPLOY_FOLDER/opt/  $SPARK_JARS  $OCI_JARS $STREAMING_JARS

#
ENV SPARK_VERSION=3.2.1
ENV HADOOP_VERSION=3.2
ENV HADOOP_VERSION_FULL=3.2.2
ENV LIVY_VERSION=0.8.0-incubating

ENV PATH $SPARK_HOME/bin/:$LIVY_HOME/bin:$PATH

USER root

RUN yum clean all
RUN  yum  update  -y && yum install epel-release -y \
     && yum install -y sudo git curl yq jq httpie unzip net-tools  vim wget software-properties-common ssh net-tools ca-certificates python-pip \
     && yum clean all


# java
RUN  yum  update  -y  && yum install -y  $JDK_NAME  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all

#maven install
RUN mkdir -p /opt/maven /opt/maven/ref
RUN echo ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
RUN curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
   && tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1 \
   && rm -f /tmp/apache-maven.tar.gz \
   && ln -s /opt/maven/bin/mvn /usr/bin/mvn



WORKDIR /build

#build spark
RUN git clone https://github.com/apache/spark.git
#git checkout v3.1.1
#./build/mvn -Pscala-2.12 -Pkubernetes -DskipTests -Phadoop-3.2 -Dhadoop.version=3.2.1 --no-transfer-progress clean package
RUN cd  /build/spark && git checkout v${SPARK_VERSION} \
    &&  ./dev/make-distribution.sh --tgz -Phadoop-${HADOOP_VERSION}  -Dhadoop.version=${HADOOP_VERSION_FULL} -Phive -Pkubernetes -Pscala-2.12 \
    && ls -alt  /build/spark/spark-3.2.1-bin-3.2.2.tgz \
    && cp  /build/spark/spark-3.2.1-bin-3.2.2.tgz $DEPLOY_FOLDER \
    && rm -rf /build/spark \
    && cd $DEPLOY_FOLDER && tar -xzvf spark-3.2.1-bin-3.2.2.tgz && rm spark-3.2.1-bin-3.2.2.tgz


#build livy
RUN git clone https://github.com/apache/incubator-livy.git
RUN cp -rf /build/incubator-livy/conf  /build/incubator-livy/conf.origin
COPY ./0.8/pom.xml /build/incubator-livy/pom.xml
COPY ./0.8/python-api/pom.xml /build/incubator-livy/python-api/pom.xml
COPY ./0.8/assembly/pom.xml /build/incubator-livy/assembly/pom.xml
COPY ./0.8/coverage/pom.xml /build/incubator-livy/coverage/pom.xml
COPY conf-livy/*  /build/incubator-livy/conf/
RUN cd  /build/incubator-livy \
    && mvn clean package -B -V -e \
            -Pspark-3.0 \
            -Pthriftserver \
            -DskipTests \
            -DskipITs \
            -Dmaven.javadoc.skip=true \
      && ls -atl  /build/incubator-livy/assembly/target/apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip \
      && cp /build/incubator-livy/assembly/target/apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip $DEPLOY_FOLDER \
      && cd /build/ && rm -rf /build/incubator-livy \
      && cd $DEPLOY_FOLDER && unzip apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip && rm apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip


# hadoop
##### is livy requires haddop lib?
#http://apache.mirrors.tds.net/hadoop/common/hadoop-${HADOOP_VERSION_FULL}/hadoop-${HADOOP_VERSION_FULL}.tar.gz
#https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION_FULL}/hadoop-${HADOOP_VERSION_FULL}.tar.gz
ENV HADOOP_URL=http://apache.mirrors.tds.net/hadoop/common/hadoop-${HADOOP_VERSION_FULL}/hadoop-${HADOOP_VERSION_FULL}.tar.gz
RUN wget ${HADOOP_URL} &&  \
    tar -xzf hadoop-${HADOOP_VERSION_FULL}.tar.gz && \
    mv hadoop-${HADOOP_VERSION_FULL} $DEPLOY_FOLDER/opt \
    && rm hadoop-${HADOOP_VERSION_FULL}.tar.gz

# OCI spark3.2.1 hadoop3.1 jar
#https://github.com/oracle/oci-hdfs-connector/releases/download/v3.3.1.0.3.2/oci-hdfs.zip
ENV HDFS_CONNECTOR_DL_URL=https://github.com/oracle/oci-hdfs-connector/releases/download/v3.2.1.3/oci-hdfs.zip
RUN mkdir -p  /build/oci-hdfs-connector/oci \
    && wget $HDFS_CONNECTOR_DL_URL  -P /build/oci-hdfs-connector \
    && unzip /build/oci-hdfs-connector/*.zip -d /build/oci-hdfs-connector/oci \
    && ls -atl  /build/oci-hdfs-connector/oci \
    && cp -r /build/oci-hdfs-connector/oci $OCI_JARS/ \
    && rm  /build/oci-hdfs-connector/*.zip


##spark stream build
#RUN mkdir -p /build/spark-streaming-pom
#COPY spark-streaming-pom.xml /build/spark-streaming-pom/pom.xml
#RUN cd /build/spark-streaming-pom && \
#        mvn dependency:copy-dependencies -DoutputDirectory=$STREAMING_JARS
#RUN ls -atl $STREAMING_JARS

#  ---------  3rdparty-jars
WORKDIR $SPARK_JARS
ARG HADOOP_AWS_VERSION=3.2.1
ARG AWS_JAVA_SDK_VERSION=1.12.183
ARG TFRECORD_VERSION=0.3.0
ARG GCS_CONNECTOR_VERSION=2.0.1
ARG BQ_CONNECTOR_VERSION=0.18.1
ARG ELASTIC_SEARCH=7.16.2
# tf
ADD https://repo1.maven.org/maven2/com/linkedin/sparktfrecord/spark-tfrecord_2.12/${TFRECORD_VERSION}/spark-tfrecord_2.12-${TFRECORD_VERSION}.jar $SPARK_JARS
#gcp
ADD https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop2-${GCS_CONNECTOR_VERSION}.jar $SPARK_JARS
ADD https://repo1.maven.org/maven2/com/google/cloud/spark/spark-bigquery-with-dependencies_2.12/${BQ_CONNECTOR_VERSION}/spark-bigquery-with-dependencies_2.12-${BQ_CONNECTOR_VERSION}.jar $SPARK_JARS
#azure
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/3.3.0/hadoop-azure-3.3.0.jar $SPARK_JARS
ADD https://repo1.maven.org/maven2/com/microsoft/azure/azure-storage/8.6.5/azure-storage-8.6.5.jar $SPARK_JARS
#jetty
ADD https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util-ajax/9.4.26.v20200117/jetty-util-ajax-9.4.26.v20200117.jar $SPARK_JARS
ADD https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-util/9.4.26.v20200117/jetty-util-9.4.26.v20200117.jar $SPARK_JARS
#oci
ADD https://repo.maven.apache.org/maven2/com/oracle/database/jdbc/ojdbc8/21.3.0.0/ojdbc8-21.3.0.0.jar $SPARK_JARS
#elasticsearch
ADD  https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-spark-20_2.12/${ELASTIC_SEARCH}/elasticsearch-spark-20_2.12-${ELASTIC_SEARCH}.jar $SPARK_JARS
#aws
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION_FULL}/hadoop-aws-${HADOOP_VERSION_FULL}.jar $SPARK_JARS
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar $SPARK_JARS


WORKDIR  $DEPLOY_FOLDER
RUN ls -altR  $DEPLOY_FOLDER
#RUN tar -xzvf spark-3.2.1-bin-3.2.2.tgz && rm spark-3.2.1-bin-3.2.2.tgz
#RUN unzip apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip
#
#RUN ls -alt  $DEPLOY_FOLDER
#RUN ls -alt  $SPARK_JAR
#RUN ls -alt  $OCI_JARS
#RUN ls -alt  $STREAMING_JARS
#RUN ls -alt  spark-3.2.1-bin-3.2.2
#RUN ls -alt  apache-livy-0.8.0-incubating-SNAPSHOT-bin

RUN mv $DEPLOY_FOLDER/spark-3.2.1-bin-3.2.2 $DEPLOY_FOLDER/opt/spark
RUN mv $DEPLOY_FOLDER/apache-livy-0.8.0-incubating-SNAPSHOT-bin $DEPLOY_FOLDER/opt/livy

RUN ls -alt  $OCI_JARS
RUN ls -alt  $DEPLOY_FOLDER
RUN ls -alt  $DEPLOY_FOLDER/*

#RUN ls -altAR  $OCI_JARS
#RUN ls -alt  $DEPLOY_FOLDER/opt/spark/jars
#RUN ls -alt  $DEPLOY_FOLDER/oci-jars/oci/lib
#RUN ls -alt  $DEPLOY_FOLDER/oci-jars/oci/third-party/lib
#RUN ls -alt  $SPARK_JARS
#RUN ls -alt  $STREAMING_JARS

RUN cp $SPARK_JARS/* $DEPLOY_FOLDER/opt/spark/jars
RUN cp $DEPLOY_FOLDER/oci-jars/oci/lib/* $DEPLOY_FOLDER/opt/spark/jars
RUN cp $DEPLOY_FOLDER/oci-jars/oci/third-party/lib/* $DEPLOY_FOLDER/opt/spark/jars


RUN mkdir -p /test/static &&  ls -altR /test/static
RUN ls -altR /usr/local/bin/



RUN echo "########################################### main CONTAINER  ###########################################"
RUN echo "########################################### main CONTAINER  ###########################################"
RUN echo "########################################### main CONTAINER  ###########################################"



########################################### main CONTAINER  ###########################################
########################################### main CONTAINER  ###########################################
########################################### main CONTAINER  ###########################################
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

ENV PATH $SPARK_HOME/bin/:$LIVY_HOME/bin:/usr/local/python3/bin/:$PATH


USER root
# ------  copy python, spark, livy, hadoop
COPY --from=builder /build/deploy/opt /opt/

RUN yum clean all
RUN yum  update  -y

RUN yum install epel-release -y
RUN yum install -y sudo git curl yq jq httpie unzip net-tools  vim wget \
     software-properties-common ssh net-tools ca-certificates python-pip \
    && yum clean all

# java
RUN yum  update  -y && yum install -y  $JDK_NAME  \
    && echo "securerandom.source=file:/dev/urandom" >> /usr/lib/jvm/jre/lib/security/java.security \
    && yum clean all


##################################################################
RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform
RUN terraform --version

##################################################################

ENV PYTHON_VERSION=3.8.12
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && set -ex \
    #  pre-install the required components
    && yum update -y \
    && yum install -y wget tar libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make initscripts \
    && yum clean all \
    # && wget https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tgz \
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
    #  configuration defaults to python3
    && ln -s /usr/local/python3/bin/python3.8 /usr/bin/python \
    && ln -s /usr/local/python3/bin/pip3 /usr/bin/pip
#  fixed due to modification of python version yum failure problem todo: yum-config-manager
RUN set -ex \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/bin/yum \
    && sed -i "s#/usr/bin/python#/usr/bin/python2.7#" /usr/libexec/urlgrabber-ext-down \
    && yum install -y deltarpm  && yum clean all



##  basic environment configuration
#RUN set -ex \
#    #  modify the time zone of the system to east zone 8
#    && rm -rf /etc/localtime \
#    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#    && yum install -y vim \
#    #  install the scheduled task component
#    && yum -y install cronie
##  support for chinese
#RUN yum install kde-l10n-Chinese -y
#RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
#  update pip version
#RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
#ENV LC_ALL zh_CN.UTF-8
#ENV TZ Asia/Shanghai

#RUN ln -sf /usr/share/zoneinfo/Asia/ShangHai /etc/localtime



##################################################################
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

COPY requirements.txt .
RUN pip install -r requirements.txt


# non root user
WORKDIR /home/centos
USER centos
RUN mkdir /home/centos/.jupyter
COPY jupyter_notebook_config.py /home/centos/.jupyter/.

# python
RUN python3 -V
RUN python -V
RUN ls -alt  /usr/local/lib
RUN ls -alt /usr/local/bin/

COPY requirements.txt .
RUN pip install -r requirements.txt

CMD ["/bin/bash", "/home/centos/statup_base.sh"]
