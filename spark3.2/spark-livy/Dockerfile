FROM  duplocloud/anyservice:spark_3_2_base_centos_v5

WORKDIR /home/centos
USER root

HEALTHCHECK CMD curl -f http://localhost:8998/ || exit 1

ENV LIVY_VERSION=0.6.0-incubating
#ENV LIVY_CONF_DIR=/etc/livy
ENV LIVY_CONF_DIR=/opt/livy/conf
ENV LIVY_LOG_DIR=/var/log/livy
ENV LIVY_LOG_FILE=/var/log/livy/livy--server.out
ENV LIVY_HOME /opt/livy
ENV LIVY_URL https://archive.apache.org/dist/incubator/livy/$LIVY_VERSION/apache-livy-$LIVY_VERSION-bin.zip
ENV PATH $LIVY_HOME/bin:$PATH

WORKDIR /opt

RUN curl -fSL $LIVY_URL -o /tmp/livy.zip \
      && unzip /tmp/livy.zip \
      && mv /opt/apache-livy-$LIVY_VERSION-bin /opt/livy-$LIVY_VERSION \
      && ls -al \
      && rm /tmp/livy.zip \
      && cd

RUN ln -s /opt/livy-$LIVY_VERSION $LIVY_HOME

RUN mkdir -p $LIVY_LOG_DIR && touch $LIVY_LOG_FILE   && ln -sf /dev/stdout $LIVY_LOG_FILE


COPY requirements.txt .
RUN pip3 install -r requirements.txt

WORKDIR /home/centos
RUN cp  -r $LIVY_HOME/conf $LIVY_HOME/conf-origin
COPY livy.conf $LIVY_CONF_DIR/livy.conf
COPY livy-env.sh  $LIVY_CONF_DIR/livy-env.sh

COPY *.sh .
RUN chmod +x *.sh

#USER centos


CMD ["/bin/bash", "/home/centos/statup-livy.sh"]
