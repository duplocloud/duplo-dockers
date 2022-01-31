FROM  duplocloud/anyservice:spark_3_2_v6
USER root
RUN apt-get update -y
RUN apt-get install -y unzip  wget  vim


###
RUN wget https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_arm64.zip
RUN unzip terraform_1.1.4_linux_arm64.zip
RUN mv terraform /usr/local/bin/
RUN terraform --version

#
COPY *.sh .
RUN chmod +x *.sh
COPY requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /home/ubuntu/tf
COPY tf-spark-cluster /home/tf
COPY test.py /home/tf
RUN ls -altR  /home/tf


CMD ["/bin/bash", "/home/ubuntu/job_statup.sh"]