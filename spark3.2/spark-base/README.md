### build spark (is centos)
* cd spark3.2/spark-base
* docker build -t duplocloud/anyservice:spark_3_2_base_v4 .
* docker login
* docker push duplocloud/anyservice:spark_3_2_base_v4
### build spark centos
* cd spark3.2/spark-base
* docker build -f Dockerfile.centos -t duplocloud/anyservice:spark_3_2_base_centos_v4 .
* docker login
* docker push duplocloud/anyservice:spark_3_2_base_centos_v4
### build spark ubuntu
* cd spark3.2/spark-base
* docker build -f Dockerfile.centos -t duplocloud/anyservice:spark_3_2_base_ubuntu_v4 .
* docker login
* docker push duplocloud/anyservice:spark_3_2_base_ubuntu_v4
  