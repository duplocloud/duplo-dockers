FROM  duplocloud/anyservice:spark_3_2_centos_v1
USER root
#RUN yum clean all
#RUN yum update -y


###
RUN wget https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_arm64.zip
RUN unzip terraform_1.1.4_linux_arm64.zip
RUN mv terraform /usr/local/bin/
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