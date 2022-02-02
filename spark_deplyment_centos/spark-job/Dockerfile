FROM  duplocloud/anyservice:spark_3_2_centos_v1
USER root


RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform
#RUN yum -y install  terraform-0.14.3-1.x86_64
RUN terraform --version


COPY requirements.txt .
RUN pip install -r requirements.txt
#
COPY *.sh .
RUN chmod +x *.sh

WORKDIR  /home/centos
COPY tf .
COPY test.py .




CMD ["/bin/bash", "/home/centos/job_statup.sh"]