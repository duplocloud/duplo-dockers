ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_v1
FROM $BASE_CONTAINER


WORKDIR /home/centos
USER root

HEALTHCHECK CMD curl -f http://localhost:8998/ || exit 1

ENV LIVY_VERSION=0.8.0-incubating
#ENV LIVY_CONF_DIR=/etc/livy
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV LIVY_LOG_DIR=/var/log/livy
ENV LIVY_LOG_FILE=/var/log/livy/livy--server.out
ENV LIVY_HOME /opt/livy
ENV LIVY_URL https://dlcdn.apache.org/incubator/livy/${LIVY_VERSION}/apache-livy-${LIVY_VERSION}-bin.zip
ENV PATH $LIVY_HOME/bin:$LIVY_HOME/jars:$LIVY_HOME/repl_2.12-jars:$PATH

WORKDIR /opt

WORKDIR /build
RUN git clone https://github.com/apache/incubator-livy.git
WORKDIR   /build/incubator-livy
RUN cp -rf /build/incubator-livy/conf  /build/incubator-livy/conf.origin
COPY ./0.8/pom.xml /build/incubator-livy/pom.xml
COPY ./0.8/python-api/pom.xml /build/incubator-livy/python-api/pom.xml
COPY ./0.8/assembly/pom.xml /build/incubator-livy/assembly/pom.xml
COPY ./0.8/coverage/pom.xml /build/incubator-livy/coverage/pom.xml
COPY conf/*  /build/incubator-livy/conf/

RUN mvn clean package -B -V -e \
        -Pspark-3.0 \
        -Pthriftserver \
        -DskipTests \
        -DskipITs \
        -Dmaven.javadoc.skip=true

# copied form emr 6.5.0 livvy 0.71
RUN cd /build/incubator-livy/assembly/target && \
     unzip apache-livy-0.8.0-incubating-SNAPSHOT-bin.zip && \
     mv apache-livy-0.8.0-incubating-SNAPSHOT-bin /opt/livy
#RUN mv /build/incubator-livy /opt/livy
RUN rm -rf /build/incubator-livy
RUN chmod -R +x /opt/livy
RUN chmod +x /opt/livy/bin/livy-server

RUN ls -alt /opt/
RUN ls -alt /opt/livy

RUN mkdir -p $LIVY_LOG_DIR && touch $LIVY_LOG_FILE   && ln -sf /dev/stdout $LIVY_LOG_FILE


# overwrite spark 3.2.1. to 3.1.1 --- which wortked done in side running docker
ENV  SPARK_VERSION=3.1.1
ENV  HADOOP_VERSION=3.2
RUN mv  /opt/spark  /opt/spark-3.2.1-hadoop-3.2
RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
        && mkdir -p /opt/spark \
        && tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
        && rm -f vapache-spark.tgz

COPY requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /home/centos

COPY *.sh .
RUN chmod +x *.sh

#USER centos


CMD ["/bin/bash", "/home/centos/statup-livy.sh"]
