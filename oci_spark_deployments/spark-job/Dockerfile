ARG BASE_CONTAINER=duplocloud/anyservice:spark_3_2_ia_v1
FROM $BASE_CONTAINER



USER root

RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform
RUN terraform --version

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY *.sh ./
RUN chmod +x *.sh

WORKDIR  /home/centos
COPY tf ./

COPY test.py ./
RUN ls -altR  ./


CMD ["/bin/bash", "/home/centos/job_statup.sh"]