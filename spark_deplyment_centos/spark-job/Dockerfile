FROM  duplocloud/anyservice:spark_3_2_centos_v1
USER root


RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
RUN yum -y install terraform
RUN terraform --version


COPY requirements.txt .
RUN pip install -r requirements.txt

#
COPY *.sh .
RUN chmod +x *.sh

WORKDIR  /home/centos
COPY tf .
COPY test.py .
RUN ls -altR  .


#RUN sed -i 's|#!/usr/bin/python|#!/usr/bin/python2|g' /usr/bin/yum
#RUN sed -i 's|#!/usr/bin/python22|#!/usr/bin/python|g' /usr/bin/yum
#



CMD ["/bin/bash", "/home/centos/job_statup.sh"]