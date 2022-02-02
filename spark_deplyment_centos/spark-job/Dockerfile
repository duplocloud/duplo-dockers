FROM  duplocloud/anyservice:spark_3_2_centos_v1
USER root
#RUN yum clean all
#RUN yum update -y
#
##ENV TERRAFORM_VERSION=1.1.4
#ENV TERRAFORM_VERSION=0.14.3
####
##RUN wget https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_arm64.zip
##RUN unzip terraform_1.1.4_linux_arm64.zip
#RUN echo "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip"
#RUN wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_arm64.zip"
#RUN unzip "terraform_${TERRAFORM_VERSION}_linux_arm64.zip"
#RUN mv terraform /usr/local/bin
#RUN terraform --version
#RUN chmod +x /usr/local/bin/terraform
#ENV PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin/:$PATH


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